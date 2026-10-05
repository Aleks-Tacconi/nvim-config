---Configure Python DAP integration.

local M = {}

---Set up Python debug adapters and configurations.
function M.setup()
	local dap = require("dap")
	local utils = require("utils.lsp")

	require("dap-python").setup(utils.get_path("python"))
	dap.configurations.python = {
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
end

return M
