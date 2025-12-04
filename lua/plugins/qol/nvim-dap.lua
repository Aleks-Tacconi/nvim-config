local utils = require("utils.lsp")

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

		vim.keymap.set("n", "<leader>bs", function()
			pickers
				.new({}, {
					prompt_title = "Debug Options",
					finder = finders.new_table({
						results = {
							"Debug Main Application",
							"Debug Tests",
							"Stop Debugging",
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
							elseif selection[1] == "Stop Debugging" then
								dap.terminate()
							end
						end)
						return true
					end,
				})
				:find()
		end)

		require("dap-python").setup(utils.get_path("python"))
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
	end,
}
