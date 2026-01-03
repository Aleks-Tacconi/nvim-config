local utils = require("utils.lsp")
local cfg = utils.lang_server()
local dap = require("dap")

require("dap-python").setup(utils.get_path("python"))

dap.configurations.python = {
	-- {
	-- 	name = "Python: Current File",
	-- 	type = "python",
	-- 	request = "launch",
	-- 	program = "${file}",
	-- 	pythonPath = require("dap-python").resolve_python,
	-- 	console = "integratedTerminal",
	-- },
	{
		name = "Django (Poetry)",
		type = "python",
		request = "launch",
		cwd = "${workspaceFolder}/backend",
		program = "${workspaceFolder}/backend/manage.py",
		args = { "runserver" },
		pythonPath = function()
			return vim.fn.system("cd backend && poetry env info -p"):gsub("\n", "") .. "/bin/python"
		end,
		django = true,
		console = "integratedTerminal",
		justMyCode = false,
	},
}

cfg:add_server("pyright", {
	settings = {
		python = {
			pythonPath = utils.get_path("python"),
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
			},
		},
	},
})
cfg:set_formatters({ "python" }, { "isort", "black" })
cfg:set_linters({ "python" }, { "pylint" })

local lint = require("lint")
lint.linters.pylint.cmd = utils.get_path("pylint")

return cfg:get()
