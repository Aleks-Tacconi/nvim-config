local utils = require("utils.lsp")
local cfg = utils.lang_server()
local dap = require("dap")

local output = vim.fn.system({
	"env",
	"NIXPKGS_ALLOW_UNFREE=1",
	"nix",
	"eval",
	"--impure",
	"--raw",
	"nixpkgs#vscode-extensions.ms-vscode.cpptools",
})
output = vim.trim(output)

dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = output .. "/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7",
}

dap.configurations.cpp = {
	-- {
	-- 	name = "Attach to gdbserver :1234",
	-- 	type = "cppdbg",
	-- 	request = "launch",
	-- 	MIMode = "gdb",
	-- 	miDebuggerServerAddress = "localhost:1234",
	-- 	miDebuggerPath = "/usr/bin/gdb",
	-- 	cwd = "${workspaceFolder}",
	-- 	program = function()
	-- 		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	-- 	end,
	-- },
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
	-- {
	-- 	name = "Christmas Project",
	-- 	type = "cppdbg",
	-- 	request = "launch",
	-- 	cwd = "${workspaceFolder}",
	-- 	stopAtEntry = true,

	-- 	program = function()
	-- 		vim.fn.system("rm -f a.out")
	-- 		local cmd = "gcc -g -O0 -Wall -Werror -Wpedantic -o a.out main.c"
	-- 		local result = vim.fn.system(cmd)

	-- 		if vim.v.shell_error ~= 0 then
	-- 			error("Build failed:\n" .. result)
	-- 		end

	-- 		return vim.fn.getcwd() .. "/a.out"
	-- 	end,

	-- 	args = function()
	-- 		-- local input = vim.fn.input("Input file: ")
	-- 		local input = "1.txt"
	-- 		-- local algo = vim.fn.input("Algorithm (FCFS/SJF/RR): ")
	-- 		local algo = "FCFS"
	-- 		return { input, algo }
	-- 	end,
	-- },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

cfg:add_server("clangd", {})
cfg:set_formatters({ "c" }, { "clang-format" })
cfg:set_linters({ "c" }, { "cpplint" })
cfg:set_indent({ "c" }, 2)

return cfg:get()
