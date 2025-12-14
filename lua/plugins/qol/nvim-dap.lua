local utils = require("utils.lsp")
local dbg_win = nil
local dbg_buf = nil

local function open_debug_help()
	if dbg_win and vim.api.nvim_win_is_valid(dbg_win) then
		return
	end

	dbg_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(dbg_buf, 0, -1, false, {
		"## DAP CHEATSHEET",
		"",
		"<leader>b1  Continue",
		"<leader>b2  Step into",
		"<leader>b3  Step over",
		"<leader>b4  Step out",
		"<leader>b6  Restart",
		"<leader>b7  Terminate",
		"<leader>b8  Disconnect",
		"<leader>b9  Close Debugger",
		"<leader>bh  Toggle Cheatsheet",
	})

	vim.bo[dbg_buf].modifiable = false
	vim.bo[dbg_buf].bufhidden = "wipe"
	vim.bo[dbg_buf].filetype = "markdown"

	local width = 36
	local height = 10

	dbg_win = vim.api.nvim_open_win(dbg_buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = 3,
		col = vim.o.columns - width - 2,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})
end

local function close_debug_help()
	if dbg_win and vim.api.nvim_win_is_valid(dbg_win) then
		vim.api.nvim_win_close(dbg_win, true)
	end
	dbg_win = nil
	dbg_buf = nil
end

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"mfussenegger/nvim-dap-python",
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("lazydev").setup({
			library = { "nvim-dap-ui" },
		})

		local dap = require("dap")
		local dapui = require("dapui")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		require("jdtls.dap").setup_dap({ hotcodereplace = "auto" })

		-- dap actions
		vim.keymap.set("n", "<leader>bt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>b1", dap.continue)
		vim.keymap.set("n", "<leader>b2", dap.step_into)
		vim.keymap.set("n", "<leader>b3", dap.step_over)
		vim.keymap.set("n", "<leader>b4", dap.step_out)
		vim.keymap.set("n", "<leader>b5", dap.step_back)
		vim.keymap.set("n", "<leader>b6", dap.restart)
		vim.keymap.set("n", "<leader>b7", dap.terminate)
		vim.keymap.set("n", "<leader>b8", dap.disconnect)
		vim.keymap.set("n", "<leader>b9", function()
			dapui.close()
			close_debug_help()
		end)
		vim.keymap.set("n", "<leader>bh", function()
			if dbg_win and vim.api.nvim_win_is_valid(dbg_win) then
				close_debug_help()
			else
				open_debug_help()
			end
		end)

		vim.keymap.set("n", "<leader>bs", function()
			pickers
				.new({}, {
					prompt_title = "Debug Options",
					finder = finders.new_table({
						results = {
							"Debug Main Application",
							"Debug Tests",
						},
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)

							if selection[1] == "Debug Tests" then
								require("jdtls.dap").test_class()
							elseif selection[1] == "Debug Main Application" then
								dap.continue()
							end
						end)
						return true
					end,
				})
				:find()
		end)

		require("dap-python").setup(utils.get_path("python"))

		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = "/nix/store/3n370qrly24cvjylzgnd0wiv9w9yw6wk-vscode-extension-ms-vscode-cpptools-1.25.3/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7",
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
			-- {
			-- 	name = "Launch file",
			-- 	type = "cppdbg",
			-- 	request = "launch",
			-- 	program = function()
			-- 		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			-- 	end,
			-- 	cwd = "${workspaceFolder}",
			-- 	stopAtEntry = true,
			-- },
			{
				name = "Christmas Project",
				type = "cppdbg",
				request = "launch",
				cwd = "${workspaceFolder}",
				stopAtEntry = true,

				program = function()
					vim.fn.system("rm -f a.out")
					local cmd = "gcc -g -O0 -Wall -Werror -Wpedantic -o a.out main.c"
					local result = vim.fn.system(cmd)

					if vim.v.shell_error ~= 0 then
						error("Build failed:\n" .. result)
					end

					return vim.fn.getcwd() .. "/a.out"
				end,

				args = function()
					local input = vim.fn.input("Input file: ")
					local algo = vim.fn.input("Algorithm (FCFS/SJF/RR): ")
					return { input, algo }
				end,
			},
		}

		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		require("dapui").setup({
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.70 },
						{ id = "breakpoints", size = 0.30 },
						-- { id = "watches", size = 0.40 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						{ id = "console", size = 0.60 },
						{ id = "repl", size = 0.40 },
					},
					size = 10,
					position = "bottom",
				},
			},
		})

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		dap.listeners.after.attach.debug_help = function()
			open_debug_help()
		end
		dap.listeners.after.launch.debug_help = function()
			open_debug_help()
		end
	end,
}
