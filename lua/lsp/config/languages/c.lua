local utils = require("utils.lsp")
local cfg = utils.lang_server()
local dap = require("dap")

-- Resolve cpptools path lazily — only when the adapter is first invoked.
-- nix eval takes ~0.8 s and is only needed for C/C++ debugging.
local cpptools_path = nil
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

cfg:add_server("clangd", {})
cfg:set_formatters({ "c" }, { "clang-format" })
cfg:set_linters({ "c" }, { "cpplint" })
cfg:set_indent({ "c" }, 2)

return cfg:get()
