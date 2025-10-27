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

		vim.keymap.set("n", "<leader>bt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>bc", dap.continue, {})

		require("dap-python").setup(utils.get_path("python"))
		require("dapui").setup()

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
