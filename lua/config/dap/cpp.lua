---Configure C, C++, and Rust DAP integration.

local M = {}

local cpptools_path

---Return the OpenDebugAD7 executable path.
---@return string
local function get_cpptools_command()
	if not cpptools_path then
		local output = vim.fn.system({
			"env",
			"NIXPKGS_ALLOW_UNFREE=1",
			"nix",
			"eval",
			"--impure",
			"--raw",
			"nixpkgs#vscode-extensions.ms-vscode.cpptools",
		})
		cpptools_path = vim.trim(output)
	end

	return cpptools_path .. "/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7"
end

---Set up native debug adapters and configurations.
function M.setup()
	local dap = require("dap")

	dap.adapters.cppdbg = {
		id = "cppdbg",
		type = "executable",
		command = get_cpptools_command,
	}

	dap.configurations.cpp = {
		{
			name = "Launch file",
			type = "cppdbg",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "function")
			end,
			cwd = "${workspaceFolder}",
			stopAtEntry = true,
			args = function()
				return { "AAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDD" }
			end,
		},
	}

	dap.configurations.c = dap.configurations.cpp
	dap.configurations.rust = dap.configurations.cpp
end

return M
