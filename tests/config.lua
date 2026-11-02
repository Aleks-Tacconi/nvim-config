---Run configuration regression checks with nvim --clean --headless -l tests/config.lua.
local root = vim.fn.getcwd()
local data = vim.fn.stdpath("data")
local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(root .. "/after")
for _, name in ipairs({
	"nvim-lspconfig",
	"blink.cmp",
	"conform.nvim",
	"nvim-lint",
	"nvim-jdtls",
	"nvim-treesitter",
	"nvim-treesitter-textobjects",
}) do
	vim.opt.rtp:append(data .. "/lazy/" .. name)
end
vim.cmd("filetype plugin off")

---Create a named, editable buffer for a regression scenario.
local function buffer(name, lines)
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_name(buf, name)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modified = false
	return buf
end

---Exercise a mapping as an actual input key sequence.
local function press(keys)
	vim.api.nvim_feedkeys(vim.keycode(keys), "xt", false)
end

---Check quickfix navigation and the requested editing options.
local function check_editor()
	dofile(root .. "/lua/config/globals.lua")
	dofile(root .. "/lua/config/options.lua")
	dofile(root .. "/lua/config/keymaps.lua")
	local buf = buffer(temp .. "/quickfix.txt", { "first", "second" })
	vim.fn.setqflist({ { bufnr = buf, lnum = 1 }, { bufnr = buf, lnum = 2 } })
	vim.cmd("cfirst")
	press("<C-l>")
	assert(vim.fn.getqflist({ idx = 0 }).idx == 2, "Ctrl-L must advance quickfix")
	press("<C-h>")
	assert(vim.fn.getqflist({ idx = 0 }).idx == 1, "Ctrl-H must reverse quickfix")
	assert(vim.fn.maparg("<C-j>", "n") == "" and vim.fn.maparg("<C-k>", "n") == "")
	for _, mode in ipairs({ "i", "c" }) do
		assert(vim.fn.maparg("<C-BS>", mode) == "<C-W>")
		assert(vim.fn.maparg("<C><BS>", mode) == "")
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
	press("ione two<C-BS><Esc>")
	assert(vim.api.nvim_get_current_line() == "one ", "Ctrl-Backspace must delete the previous word")
	assert(not vim.o.backup and not vim.o.writebackup and not vim.o.swapfile)
	assert(vim.o.undofile and vim.o.mouse == "a")
	for _, command in ipairs({ "W", "Q", "Wq", "WQ", "Wqa", "WQa", "WQA", "Wa", "WA" }) do
		assert(vim.api.nvim_get_commands({})[command] == nil, "Unexpected command alias: " .. command)
	end
end

---Ensure notebook initialization cannot mutate buffers through screenpos or delete Markdown.
local function check_notebooks()
	local nb = require("utils.notebook")
	local screenpos = vim.fn.screenpos
	nb.init()
	assert(vim.fn.screenpos == screenpos, "Notebook setup must not replace screenpos")
	local buf = buffer(temp .. "/scratch.txt", { "keep this" })
	pcall(vim.fn.screenpos, 0, 100, 1)
	assert(vim.api.nvim_buf_line_count(buf) == 1, "Position lookups must not add lines")
	local notebook = temp .. "/notes.ipynb"
	local markdown = temp .. "/notes.md"
	assert(nb.write_template(notebook))
	vim.fn.writefile({ "independent notes" }, markdown)
	nb.setup()
	for _, event in ipairs({ "BufWritePost", "BufUnload" }) do
		vim.api.nvim_exec_autocmds(event, { pattern = notebook })
	end
	assert(vim.deep_equal(vim.fn.readfile(markdown), { "independent notes" }))
end

---Retry a transient module-loading failure on the next filetype event.
local function check_retry_imports(enabled)
	local attempts = 0
	local notify = vim.notify
	vim.notify = function() end
	package.preload["lsp.config.languages.xml"] = function()
		attempts = attempts + 1
		if attempts == 1 then
			error("Temporary language import failure")
		end
		return { servers = { lemminx = {} } }
	end
	vim.bo.filetype = "xml"
	vim.api.nvim_exec_autocmds("FileType", {})
	assert(attempts == 2 and enabled.lemminx, "Failed language imports must be retryable")
	vim.notify = notify
	package.preload["lsp.config.languages.xml"] = nil
	package.loaded["lsp.config.languages.xml"] = nil
end

---Check formerly missed filetypes, per-project Java workspaces, and SQL diagnostics.
local function check_languages()
	local enabled = {}
	local enable = vim.lsp.enable
	vim.lsp.enable = function(name)
		enabled[name] = true
	end
	dofile(root .. "/lua/lsp/plugins/nvim-lspconfig.lua").config()
	for ft, server in pairs({
		dockerfile = "dockerls",
		["yaml.docker-compose"] = "docker_compose_language_service",
		qmljs = "qmlls",
		cpp = "clangd",
		sql = "postgres_lsp",
		java = "jdtls",
	}) do
		vim.bo.filetype = ft
		assert(enabled[server], ft .. " must enable " .. server)
	end
	check_retry_imports(enabled)
	vim.lsp.enable = enable
	vim.api.nvim_del_augroup_by_name("language-tooling")
	local lint = require("lint").linters.sqlfluff
	assert(not vim.tbl_contains(lint.args, "%file") and lint.stdin)
	local output = vim.json.encode({
		{
			filepath = "stdin",
			violations = {
				{ line_no = 2, line_pos = 3, code = "LT01", description = "Trailing whitespace" },
			},
		},
	})
	local diagnostics = lint.parser(output)
	assert(#diagnostics == 1 and diagnostics[1].lnum == 1 and diagnostics[1].col == 2)
	local commands = {}
	local start = vim.lsp.rpc.start
	vim.lsp.rpc.start = function(cmd)
		table.insert(commands, cmd)
	end
	for _, project in ipairs({ "/one/app", "/two/app" }) do
		vim.lsp.config.jdtls.cmd({}, { root_dir = project })
	end
	vim.lsp.rpc.start = start
	assert(commands[1][1] == "jdtls" and commands[1][3] ~= commands[2][3])
end

---Resolve project executables correctly even when Neovim's working directory differs.
local function check_executables()
	local project = temp .. "/project"
	vim.fn.mkdir(project .. "/.venv/bin", "p")
	vim.fn.mkdir(project .. "/src", "p")
	local tool = project .. "/.venv/bin/audit-tool"
	vim.fn.writefile({ "#!/bin/sh", "exit 0" }, tool)
	assert(vim.fn.setfperm(tool, "rwx------") == 1)
	local utils = require("utils.lsp")
	assert(utils.get_path("audit-tool", project .. "/src/example.py") == tool)
	assert(utils.get_path("audit-tool", project) == tool)
	assert(utils.get_path("missing-audit-tool", project) == "missing-audit-tool")
end

---Verify native highlighting, injected Python, and real notebook cell movement.
local function check_treesitter()
	require("config.treesitter").setup()
	local buf = buffer(temp .. "/cells.md", {
		"# Notebook",
		"",
		"```python",
		"x = 1",
		"```",
		"",
		"```python",
		"y = 2",
		"```",
	})
	vim.bo.filetype = "markdown"
	assert(vim.treesitter.highlighter.active[buf], "Markdown highlighting must start")
	local parser = vim.treesitter.get_parser(buf, "markdown")
	parser:parse(true)
	local query = vim.treesitter.query.get("markdown", "textobjects")
	assert(query and vim.tbl_contains(query.captures, "code_cell.inner"))
	local found_python = false
	parser:for_each_tree(function(_, language)
		found_python = found_python or language:lang() == "python"
	end)
	assert(found_python, "Python fences must have an injected parser")
	require("nvim-treesitter-textobjects").setup({ move = { set_jumps = false } })
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	require("nvim-treesitter-textobjects.move").goto_next_start("@code_cell.inner", "textobjects")
	assert(vim.api.nvim_win_get_cursor(0)[1] == 4, "Cell movement must find the first cell")
end

check_editor()
check_notebooks()
check_languages()
check_executables()
check_treesitter()
print("All configuration regression checks passed")
