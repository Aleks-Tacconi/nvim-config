---Configure Jupyter notebook editing, kernel execution, and cell navigation.
local M = {}
local margin_ns = vim.api.nvim_create_namespace("notebook_active_cell_margin")
local cell_query
local active_cell_cache = {}

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
	"  :NewNotebook      Create and open a new blank notebook",
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

---Normalize an `.ipynb` cell `source` field (string or list of lines) into a line array.
local function source_to_lines(src)
	if type(src) == "string" then
		return src == "" and {} or vim.split(src:gsub("\n$", ""), "\n", { plain = true })
	elseif type(src) == "table" then
		local text = table.concat(src, "")
		return text == "" and {} or vim.split(text:gsub("\n$", ""), "\n", { plain = true })
	end
	return {}
end

---Encode a line array into the standard `.ipynb` `source` array format.
local function lines_to_source(lines)
	if #lines == 0 or (#lines == 1 and lines[1] == "") then
		return {}
	end
	local out = {}
	for i, line in ipairs(lines) do
		out[i] = i < #lines and (line .. "\n") or line
	end
	return out
end

---Read and decode an `.ipynb` JSON file from disk.
local function read_ipynb_json(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local raw = file:read("*a")
	file:close()
	local ok, nb = pcall(vim.json.decode, raw)
	if not ok or type(nb) ~= "table" then
		return nil
	end
	return nb
end

---Convert `.ipynb` JSON into Markdown buffer lines (without spawning `jupytext`).
local function ipynb_to_markdown(nb)
	local meta = nb.metadata or {}
	local ks = meta.kernelspec or {}
	local li = meta.language_info or {}
	local lang = ks.language or li.name or "python"
	local lines = {}

	for idx, cell in ipairs(nb.cells or {}) do
		local src = source_to_lines(cell.source)
		if cell.cell_type == "code" then
			lines[#lines + 1] = "```" .. lang
			if #src == 0 then
				lines[#lines + 1] = ""
			else
				vim.list_extend(lines, src)
			end
			lines[#lines + 1] = "```"
		else
			vim.list_extend(lines, src)
		end
		if idx < #(nb.cells or {}) then
			lines[#lines + 1] = ""
		end
	end

	if #lines == 0 then
		lines = { "```" .. lang, "", "```" }
	end
	return lines
end

---Parse Markdown buffer lines back into `.ipynb` cells while preserving saved cell outputs.
local function markdown_to_cells(buf_lines, old_cells)
	local start_idx = 1
	if buf_lines[1] == "---" then
		for i = 2, math.min(#buf_lines, 40) do
			if buf_lines[i] == "---" then
				start_idx = i + 1
				if buf_lines[start_idx] == "" then
					start_idx = start_idx + 1
				end
				break
			end
		end
	end

	local parsed = {}
	local md_lines = {}
	local i = start_idx

	local function flush_md()
		local first, last = 1, #md_lines
		while first <= last and md_lines[first] == "" do
			first = first + 1
		end
		while last >= first and md_lines[last] == "" do
			last = last - 1
		end
		if first <= last then
			local slice = {}
			for j = first, last do
				slice[#slice + 1] = md_lines[j]
			end
			parsed[#parsed + 1] = { cell_type = "markdown", lines = slice }
		end
		md_lines = {}
	end

	while i <= #buf_lines do
		local fence = buf_lines[i]:match("^```([%w_%-%.]*)$")
		if fence ~= nil then
			flush_md()
			local code_lines = {}
			i = i + 1
			while i <= #buf_lines and not buf_lines[i]:match("^```%s*$") do
				code_lines[#code_lines + 1] = buf_lines[i]
				i = i + 1
			end
			parsed[#parsed + 1] = { cell_type = "code", lines = code_lines }
			i = i + 1
		else
			md_lines[#md_lines + 1] = buf_lines[i]
			i = i + 1
		end
	end
	flush_md()

	-- Pool existing code cells by source content so outputs and execution_count survive edits.
	local old_code_by_src = {}
	local old_code_by_idx = {}
	for _, c in ipairs(old_cells or {}) do
		if c.cell_type == "code" then
			old_code_by_idx[#old_code_by_idx + 1] = c
			local key = table.concat(source_to_lines(c.source), "\n")
			old_code_by_src[key] = old_code_by_src[key] or {}
			table.insert(old_code_by_src[key], c)
		end
	end

	local used_old = {}
	local matched_by_idx = {}
	local new_cells = {}
	local code_seq = 0

	for idx, item in ipairs(parsed) do
		if item.cell_type == "code" then
			local key = table.concat(item.lines, "\n")
			local bucket = old_code_by_src[key]
			if bucket then
				for _, candidate in ipairs(bucket) do
					if not used_old[candidate] then
						matched_by_idx[idx] = candidate
						used_old[candidate] = true
						break
					end
				end
			end
		end
	end

	for idx, item in ipairs(parsed) do
		if item.cell_type == "code" then
			code_seq = code_seq + 1
			local matched = matched_by_idx[idx]
			if not matched and old_code_by_idx[code_seq] and not used_old[old_code_by_idx[code_seq]] then
				matched = old_code_by_idx[code_seq]
				used_old[matched] = true
			end

			new_cells[#new_cells + 1] = {
				id = (matched and matched.id) or ("cell-" .. idx),
				cell_type = "code",
				execution_count = (matched and matched.execution_count ~= nil) and matched.execution_count or vim.NIL,
				metadata = (matched and type(matched.metadata) == "table") and matched.metadata or vim.empty_dict(),
				outputs = (matched and type(matched.outputs) == "table") and matched.outputs or {},
				source = lines_to_source(item.lines),
			}
		else
			new_cells[#new_cells + 1] = {
				id = "cell-" .. idx,
				cell_type = "markdown",
				metadata = vim.empty_dict(),
				source = lines_to_source(item.lines),
			}
		end
	end

	return new_cells
end

---Load an `.ipynb` file into buffer `buf` natively without calling `jupytext`.
function M.read_buf(buf, path)
	local full_path = vim.fn.resolve(vim.fn.expand(path))
	local nb = read_ipynb_json(full_path) or vim.json.decode(DEFAULT_NOTEBOOK_JSON)
	local lines = ipynb_to_markdown(nb)
	vim.b[buf].notebook_kernel = ((nb.metadata or {}).kernelspec or {}).name

	local levels = vim.bo[buf].undolevels
	vim.bo[buf].undolevels = -1
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].undolevels = levels
	vim.bo[buf].modified = false
	vim.bo[buf].fileencoding = "utf-8"
	vim.bo[buf].filetype = "markdown"
end

---Write buffer `buf` back to its `.ipynb` JSON file on disk without calling `jupytext`.
function M.write_buf(buf, path, drop_outputs)
	local full_path = vim.fn.resolve(vim.fn.expand(path))
	local nb = read_ipynb_json(full_path) or vim.json.decode(DEFAULT_NOTEBOOK_JSON)
	local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	nb.cells = markdown_to_cells(buf_lines, drop_outputs and {} or nb.cells)
	nb.nbformat = nb.nbformat or 4
	nb.nbformat_minor = nb.nbformat_minor or 5
	if type(nb.metadata) ~= "table" then
		nb.metadata = vim.json.decode(DEFAULT_NOTEBOOK_JSON).metadata
	end

	local file = io.open(full_path, "w")
	if not file then
		vim.notify("Failed to write notebook: " .. full_path, vim.log.levels.ERROR)
		return false
	end
	file:write(vim.json.encode(nb) .. "\n")
	file:close()
	vim.bo[buf].modified = false
	vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf, modeline = false })
	return true
end

---Set Molten defaults and register native `.ipynb` read/write handlers.
function M.init()
	local io_group = vim.api.nvim_create_augroup("notebook_ipynb_io", { clear = true })
	vim.api.nvim_create_autocmd("BufReadCmd", {
		group = io_group,
		pattern = "*.ipynb",
		callback = function(ev)
			M.read_buf(ev.buf, ev.match)
		end,
	})
	vim.api.nvim_create_autocmd({ "BufWriteCmd", "FileWriteCmd" }, {
		group = io_group,
		pattern = "*.ipynb",
		callback = function(ev)
			M.write_buf(ev.buf, ev.match)
		end,
	})

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
	local loaded = vim.fn.exists("#molten#CursorMoved") == 1 or vim.fn.exists("*MoltenRunningKernels") == 1
	local kernels = loaded and vim.fn.MoltenRunningKernels(true) or {}
	if #kernels == 0 then
		return "Kernel: not started"
	end
	return "Kernel: " .. table.concat(kernels, ", ")
end

---Discover available Jupyter kernels directly from standard kernelspec directories.
local function discover_kernels()
	local dirs = {
		vim.fn.expand("~/.local/share/jupyter/kernels"),
		vim.fn.expand("~/Library/Jupyter/kernels"),
		"/usr/local/share/jupyter/kernels",
		"/usr/share/jupyter/kernels",
	}
	if vim.env.JUPYTER_PATH then
		for _, p in ipairs(vim.split(vim.env.JUPYTER_PATH, ":", { plain = true, trimempty = true })) do
			dirs[#dirs + 1] = p .. "/kernels"
		end
	end
	if vim.env.VIRTUAL_ENV then
		dirs[#dirs + 1] = vim.env.VIRTUAL_ENV .. "/share/jupyter/kernels"
	end
	if vim.env.NVIM_PYTHON_PROVIDER then
		local prefix = vim.fn.fnamemodify(vim.env.NVIM_PYTHON_PROVIDER, ":h:h")
		dirs[#dirs + 1] = prefix .. "/share/jupyter/kernels"
	end

	local seen, kernels = {}, {}
	for _, dir in ipairs(dirs) do
		local matches = vim.fn.glob(dir .. "/*/kernel.json", true, true)
		for _, match in ipairs(matches) do
			local name = vim.fn.fnamemodify(match, ":h:t")
			if name ~= "" and not seen[name] then
				seen[name] = true
				kernels[#kernels + 1] = name
			end
		end
	end

	if #kernels > 0 then
		table.sort(kernels)
		return kernels
	end
	local ok, fallback = pcall(vim.fn.MoltenAvailableKernels)
	return (ok and type(fallback) == "table") and fallback or {}
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
	local declared = header:match("kernelspec:.-name:%s*([%w_%-%.]+)") or vim.b[buf].notebook_kernel
	local available = discover_kernels()

	local function start(kernel_name)
		if not kernel_name or not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("notebook_ready_" .. buf, { clear = true }),
			pattern = "MoltenKernelReady",
			once = true,
			callback = function()
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(buf) then
						vim.api.nvim_buf_call(buf, function()
							M.load_outputs()
							if callback then
								callback()
							end
						end)
					end
				end)
			end,
		})
		vim.api.nvim_buf_call(buf, function()
			vim.cmd.MoltenInit({ args = { kernel_name } })
		end)
	end

	if #available == 0 then
		return
	end
	if not opts.prompt and declared and vim.list_contains(available, declared) then
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
	if not tree then
		return {}
	end
	cell_query = cell_query or vim.treesitter.query.parse("markdown", "(fenced_code_block) @cell")
	local result = {}
	for _, node in cell_query:iter_captures(tree:root(), buf) do
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
function M.highlight(buf, force)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local win = vim.fn.bufwinid(buf)
	if win == -1 then
		return
	end
	local row = vim.api.nvim_win_get_cursor(win)[1] - 1
	local cached = active_cell_cache[buf]
	if not force and cached and row >= cached.first and row < cached.last then
		return
	end

	vim.api.nvim_buf_clear_namespace(buf, margin_ns, 0, -1)
	local all = cell_ranges(buf)
	local idx = current_cell(all, row)
	if not idx then
		active_cell_cache[buf] = nil
		return
	end
	active_cell_cache[buf] = all[idx]
	for r = all[idx].first, all[idx].last - 1 do
		vim.api.nvim_buf_set_extmark(buf, margin_ns, r, 0, {
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
		M.initialize(function()
			pcall(vim.cmd, "MoltenImportOutput")
		end)
	end
end

---Save the notebook and explicitly export Molten outputs into `.ipynb`.
function M.save_outputs()
	vim.cmd("write")
	if M.attached() then
		vim.cmd("MoltenExportOutput!")
	end
end

---Clear saved outputs from the `.ipynb` file on disk and stop the attached kernel.
function M.clear_outputs()
	local buf = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf)
	if not is_notebook(path) then
		return
	end
	if M.attached() then
		pcall(vim.cmd, "MoltenDeinit")
	end
	if M.write_buf(buf, path, true) then
		vim.notify("Cleared notebook outputs", vim.log.levels.INFO)
	end
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

---Evaluate one fenced code cell with Molten.
local function evaluate_cell(cell)
	if cell and cell.last - 1 > cell.first + 1 then
		vim.fn.MoltenEvaluateRange(cell.first + 2, cell.last - 1)
	end
end

---Run a cell action (`cell`, `above`, or `all`) after ensuring the kernel is attached.
local function run(scope, advance)
	return function()
		M.initialize(function()
			local all = cell_ranges(0)
			local row = vim.api.nvim_win_get_cursor(0)[1] - 1
			if scope == "cell" then
				local idx = current_cell(all, row)
				if idx then
					evaluate_cell(all[idx])
				end
			elseif scope == "above" then
				for _, cell in ipairs(all) do
					if cell.first <= row then
						evaluate_cell(cell)
					end
				end
			elseif scope == "all" then
				for _, cell in ipairs(all) do
					evaluate_cell(cell)
				end
			end
			if advance then
				M.move(1)
			end
		end)
	end
end

---Run the active visual selection.
function M.run_selection()
	local start_line = vim.fn.getpos("'<")[2]
	local end_line = vim.fn.getpos("'>")[2]
	if start_line > 0 and end_line >= start_line then
		M.initialize(function()
			vim.fn.MoltenEvaluateRange(start_line, end_line)
		end)
	end
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
		{ "n", "<localleader>rc", run("cell"), "Run cell" },
		{ "n", "<localleader>rj", run("cell", true), "Run cell and advance" },
		{ "n", "<localleader>ra", run("above"), "Run through current cell" },
		{ "n", "<localleader>rA", run("all"), "Run all cells" },
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
		{ "n", "<localleader>nh", M.show_help, "Notebook shortcuts" },
	}
	for _, m in ipairs(maps) do
		vim.keymap.set(m[1], m[2], m[3], { buffer = buf, desc = m[4], silent = true })
	end

	local group = vim.api.nvim_create_augroup("notebook_cells_" .. buf, { clear = true })
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = group,
		buffer = buf,
		callback = function()
			M.highlight(buf, false)
		end,
	})
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter" }, {
		group = group,
		buffer = buf,
		callback = function()
			M.highlight(buf, true)
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		buffer = buf,
		callback = function()
			active_cell_cache[buf] = nil
		end,
	})
	M.highlight(buf, true)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		local ok_otter, otter = pcall(require, "otter")
		if ok_otter then
			vim.api.nvim_buf_call(buf, function()
				otter.activate({ "python" }, true, true)
			end)
		end
		if vim.api.nvim_get_current_buf() == buf and not M.attached() then
			M.initialize(nil, { prompt = true })
		end
	end)
end

---Register notebook autocommands and user commands.
function M.setup()
	local group = vim.api.nvim_create_augroup("notebook_setup", { clear = true })
	vim.api.nvim_create_autocmd("FileType", { group = group, pattern = "markdown", callback = attach })
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
			attach({ buf = buf })
		end
	end
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
	vim.api.nvim_create_user_command("NotebookLoadOutputs", M.load_outputs, {})
	vim.api.nvim_create_user_command("NotebookSaveOutputs", M.save_outputs, {})
	vim.api.nvim_create_user_command("NotebookClearOutputs", M.clear_outputs, {})
	vim.api.nvim_create_user_command("MoltenClearExport", M.clear_outputs, {})
	vim.api.nvim_create_user_command("NotebookHelp", M.show_help, {})
end

return M
