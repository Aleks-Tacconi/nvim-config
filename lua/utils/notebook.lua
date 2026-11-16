---Configure Jupyter notebook editing, kernel execution, and cell navigation.
local M = {}
local margin_ns = vim.api.nvim_create_namespace("notebook_active_cell_margin")

local DEFAULT_NOTEBOOK_JSON = vim.json.encode({
	cells = {
		{
			id = "cell-1",
			cell_type = "code",
			execution_count = vim.NIL,
			metadata = vim.empty_dict(),
			outputs = {},
			source = {},
		},
	},
	metadata = {
		kernelspec = { display_name = "Python 3", language = "python", name = "python3" },
		language_info = { name = "python", version = "3" },
	},
	nbformat = 4,
	nbformat_minor = 5,
})

local HELP_LINES = {
	"# Notebook Shortcuts & Commands",
	"",
	"  Tab / Shift-Tab   Next / previous code cell (Normal mode)",
	"  <space>na / nb    Insert code cell above / below",
	"  <space>rc / rj    Run cell / Run cell and advance",
	"  <space>ra / rA    Run above / Run all cells",
	"  <space>r          Run visual selection",
	"  <space>mi / mr    Initialize / Restart kernel",
	"  <space>mk / mx    Kernel info / Interrupt execution",
	"  <space>os / oh    Enter / Hide output window",
	"  <space>ol / ox    Load saved outputs / Save & export outputs",
	"  <space>op         Export notebook to PDF",
	"  :NewNotebook      Create and open a new blank notebook",
	"  :NotebookToPdf    Export to PDF (pdf, typst, webpdf)",
	"  :NotebookHelp     Open this cheatsheet",
}

---Return true when path points to a Jupyter notebook.
local function is_notebook(path)
	return path:match("%.ipynb$") ~= nil
end

---Return true when an `.ipynb` file contains at least one code cell with outputs.
local function has_saved_outputs(path)
	local file = io.open(path, "r")
	if not file then
		return false
	end
	local raw = file:read("*a")
	file:close()
	local ok, nb = pcall(vim.json.decode, raw)
	if not ok or type(nb) ~= "table" or type(nb.cells) ~= "table" then
		return false
	end
	for _, cell in ipairs(nb.cells) do
		if cell.cell_type == "code" and type(cell.outputs) == "table" and #cell.outputs > 0 then
			return true
		end
	end
	return false
end

---Set Molten defaults before the remote plugin loads.
function M.init()
	vim.g.molten_auto_open_output = false
	vim.g.molten_image_provider = "image.nvim"
	vim.g.molten_image_location = "both"
	vim.g.molten_virt_text_output = true
	vim.g.molten_virt_text_max_lines = 12
	vim.g.molten_virt_lines_off_by_1 = true
	vim.g.molten_output_show_exec_time = true
	vim.g.molten_output_win_border = "rounded"
	vim.g.molten_output_win_hide_on_leave = true
	vim.g.molten_output_win_style = "minimal"
	vim.g.molten_output_win_max_height = 20
	vim.g.molten_output_win_max_width = 100
	vim.g.molten_enter_output_behavior = "open_and_enter"
	vim.g.molten_wrap_output = true
end

---Check whether the current buffer has an active Molten kernel.
function M.attached()
	local loaded = vim.fn.exists("#molten#CursorMoved") == 1 or vim.fn.exists("*MoltenRunningKernels") == 1
	return loaded and #vim.fn.MoltenRunningKernels(true) > 0
end

---Return the statusline kernel label for notebook buffers.
function M.status()
	if not is_notebook(vim.api.nvim_buf_get_name(0)) then
		return ""
	end
	if not M.attached() then
		return "Kernel: not started"
	end
	return "Kernel: " .. table.concat(vim.fn.MoltenRunningKernels(true), ", ")
end

---Start the kernel declared in the YAML header or prompt for an available one.
function M.initialize(callback, opts)
	opts = opts or {}
	if M.attached() then
		if callback then
			callback()
		end
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	local header = table.concat(vim.api.nvim_buf_get_lines(buf, 0, 25, false), "\n")
	local declared = header:match("kernelspec:.-name:%s*([%w_%-%.]+)")
	local available = vim.fn.MoltenAvailableKernels()

	local function start(kernel_name)
		if not kernel_name or not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		if callback then
			vim.api.nvim_create_autocmd("User", {
				pattern = "MoltenKernelReady",
				once = true,
				callback = function()
					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(buf) then
							vim.api.nvim_buf_call(buf, callback)
						end
					end)
				end,
			})
		end
		vim.api.nvim_buf_call(buf, function()
			vim.cmd.MoltenInit({ args = { kernel_name } })
		end)
	end

	if #available == 0 then
		return
	end
	if not opts.prompt and declared and vim.tbl_contains(available, declared) then
		start(declared)
	else
		vim.ui.select(available, { prompt = "Notebook kernel:" }, start)
	end
end

---Read fenced code block line ranges from the Markdown syntax tree.
local function cell_ranges(buf)
	local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
	if not ok or not parser then
		return {}
	end
	local tree = parser:parse()[1]
	local query = vim.treesitter.query.parse("markdown", "(fenced_code_block) @cell")
	local result = {}
	for _, node in query:iter_captures(tree:root(), buf) do
		local first, _, last, col = node:range()
		result[#result + 1] = { first = first, last = last + (col > 0 and 1 or 0) }
	end
	return result
end

---Return the index of the cell containing a zero-based cursor row.
local function current_cell(all, row)
	for i, cell in ipairs(all) do
		if row >= cell.first and row < cell.last then
			return i
		end
	end
end

---Jump to the next or previous code cell.
function M.move(direction)
	local all = cell_ranges(0)
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local idx = current_cell(all, row)
	local target = idx and all[idx + direction * vim.v.count1]
	if not target then
		for _, cell in ipairs(all) do
			if direction > 0 and cell.first > row then
				target = cell
				break
			elseif direction < 0 and cell.last <= row then
				target = cell
			end
		end
	end
	if target then
		vim.api.nvim_win_set_cursor(0, { math.min(target.first + 2, vim.api.nvim_buf_line_count(0)), 0 })
		vim.cmd("normal! zv")
	end
end

---Insert a fenced Python cell above or below the current cell.
function M.insert(below)
	local all = cell_ranges(0)
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local idx = current_cell(all, row)
	local cell = idx and all[idx]
	local at = cell and (below and cell.last or cell.first) or (row + (below and 1 or 0))
	vim.api.nvim_buf_set_lines(0, at, at, false, { "", "```python", "", "```", "" })
	vim.api.nvim_win_set_cursor(0, { at + 3, 0 })
	vim.cmd("startinsert")
end

---Draw a sign bar in the margin for the active code cell.
function M.highlight(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, margin_ns, 0, -1)
	local all = cell_ranges(buf)
	local idx = current_cell(all, vim.api.nvim_win_get_cursor(0)[1] - 1)
	if not idx then
		return
	end
	for row = all[idx].first, all[idx].last - 1 do
		vim.api.nvim_buf_set_extmark(buf, margin_ns, row, 0, {
			sign_text = "▎",
			sign_hl_group = "NotebookActiveCellMargin",
			priority = 20,
		})
	end
end

---Write a blank `.ipynb` template to disk and open it.
function M.create_new_notebook(filename)
	local path = is_notebook(filename) and filename or (filename .. ".ipynb")
	if vim.fn.filereadable(path) == 0 then
		local file = io.open(path, "w")
		if not file then
			vim.notify("Could not create notebook: " .. path, vim.log.levels.ERROR)
			return
		end
		file:write(DEFAULT_NOTEBOOK_JSON)
		file:close()
	end
	vim.cmd.edit({ args = { path } })
end

---Import saved `.ipynb` outputs into Molten for the current notebook buffer.
function M.load_outputs()
	local path = vim.api.nvim_buf_get_name(0)
	if not is_notebook(path) or not has_saved_outputs(path) then
		return
	end
	if M.attached() then
		pcall(vim.cmd, "MoltenImportOutput")
	else
		M.initialize()
	end
end

---Save the notebook and explicitly export Molten outputs into `.ipynb`.
function M.save_outputs()
	vim.cmd("write")
	if M.attached() then
		vim.cmd("MoltenExportOutput!")
	end
end

---Clear saved outputs from the `.ipynb` file on disk via nbconvert.
function M.clear_outputs()
	local path = vim.api.nvim_buf_get_name(0)
	if not is_notebook(path) then
		return
	end
	vim.cmd("write")
	vim.system(
		{ "jupyter", "nbconvert", "--clear-output", "--inplace", path },
		{ text = true },
		vim.schedule_wrap(function(res)
			local level = res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
			vim.notify(res.code == 0 and "Cleared notebook outputs" or ("Clear outputs failed:\n" .. res.stderr), level)
		end)
	)
end

---Export the current notebook to PDF using Quarto or nbconvert.
function M.export_to_pdf(fmt)
	local path = vim.api.nvim_buf_get_name(0)
	if not is_notebook(path) then
		return
	end
	vim.cmd("write")
	local cmd = vim.fn.executable("quarto") == 1
			and { "quarto", "render", path, "--to", fmt or "pdf", "--no-execute" }
		or { "jupyter", "nbconvert", "--to", fmt or "pdf", path }
	vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
		local level = res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
		vim.notify(res.code == 0 and "Exported PDF" or ("PDF export failed:\n" .. res.stderr), level)
	end))
end

---Display the floating shortcut cheatsheet.
function M.show_help()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, HELP_LINES)
	vim.bo[buf].filetype = "markdown"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modifiable = false
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 62,
		height = #HELP_LINES,
		row = math.floor((vim.o.lines - #HELP_LINES) / 2),
		col = math.floor((vim.o.columns - 62) / 2),
		style = "minimal",
		border = "rounded",
		title = " Notebook Cheatsheet ",
		title_pos = "center",
	})
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = buf, silent = true, nowait = true })
	end
end

---Run a Quarto runner method after ensuring the kernel is attached.
local function run(method, advance)
	return function()
		M.initialize(function()
			require("quarto.runner")[method]()
			if advance then
				M.move(1)
			end
		end)
	end
end

---Run the active visual selection.
function M.run_selection()
	run("run_range")()
end

---Attach notebook-local keymaps, options, and margin highlights.
local function attach(event)
	local buf = event.buf
	if not is_notebook(vim.api.nvim_buf_get_name(buf)) then
		return
	end
	vim.opt_local.spell = false
	vim.opt_local.colorcolumn = ""
	vim.opt_local.conceallevel = 2
	vim.opt_local.concealcursor = "nc"

	local maps = {
		{ "n", "<Tab>", function() M.move(1) end, "Next code cell" },
		{ "n", "<S-Tab>", function() M.move(-1) end, "Previous code cell" },
		{ "n", "<localleader>rc", run("run_cell"), "Run cell" },
		{ "n", "<localleader>rj", run("run_cell", true), "Run cell and advance" },
		{ "n", "<localleader>ra", run("run_above"), "Run through current cell" },
		{ "n", "<localleader>rA", run("run_all"), "Run all cells" },
		{ "x", "<localleader>r", ":<C-u>lua require('utils.notebook').run_selection()<CR>", "Run selection" },
		{ "n", "<localleader>na", function() M.insert(false) end, "Insert code cell above" },
		{ "n", "<localleader>nb", function() M.insert(true) end, "Insert code cell below" },
		{ "n", "<localleader>mi", M.initialize, "Initialize notebook kernel" },
		{ "n", "<localleader>mk", "<cmd>MoltenInfo<CR>", "Kernel information" },
		{ "n", "<localleader>mx", "<cmd>MoltenInterrupt<CR>", "Interrupt execution" },
		{ "n", "<localleader>mr", "<cmd>MoltenRestart<CR>", "Restart kernel" },
		{ "n", "<localleader>os", "<cmd>noautocmd MoltenEnterOutput<CR>", "Inspect full output" },
		{ "n", "<localleader>oh", "<cmd>MoltenHideOutput<CR>", "Close output inspector" },
		{ "n", "<localleader>ol", M.load_outputs, "Load saved outputs" },
		{ "n", "<localleader>ox", M.save_outputs, "Save notebook and outputs" },
		{ "n", "<localleader>op", M.export_to_pdf, "Export notebook to PDF" },
		{ "n", "<localleader>nh", M.show_help, "Notebook shortcuts" },
	}
	for _, m in ipairs(maps) do
		vim.keymap.set(m[1], m[2], m[3], { buffer = buf, desc = m[4], silent = true })
	end

	local group = vim.api.nvim_create_augroup("notebook_cells_" .. buf, { clear = true })
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "BufEnter" }, {
		group = group,
		buffer = buf,
		callback = function()
			M.highlight(buf)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MoltenKernelReady",
		once = true,
		callback = function()
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_call(buf, M.load_outputs)
				end
			end)
		end,
	})
	M.highlight(buf)
	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_current_buf() == buf and not M.attached() then
			M.initialize(nil, { prompt = true })
		end
	end)
end

---Register notebook autocommands and user commands.
function M.setup()
	local group = vim.api.nvim_create_augroup("notebook_setup", { clear = true })
	vim.api.nvim_create_autocmd("FileType", { group = group, pattern = "markdown", callback = attach })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "molten_output",
		callback = function(event)
			for _, key in ipairs({ "q", "<Esc>" }) do
				vim.keymap.set("n", key, "<cmd>close<CR>", { buffer = event.buf, silent = true })
			end
		end,
	})
	vim.api.nvim_create_user_command("NewNotebook", function(opts)
		M.create_new_notebook(opts.args)
	end, { nargs = 1, complete = "file" })
	vim.api.nvim_create_user_command("NotebookToPdf", function(opts)
		M.export_to_pdf(opts.args ~= "" and opts.args or nil)
	end, { nargs = "?" })
	vim.api.nvim_create_user_command("NotebookLoadOutputs", M.load_outputs, {})
	vim.api.nvim_create_user_command("NotebookSaveOutputs", M.save_outputs, {})
	vim.api.nvim_create_user_command("MoltenClearExport", M.clear_outputs, {})
	vim.api.nvim_create_user_command("NotebookHelp", M.show_help, {})
end

return M
