return {
	"nvim-neo-tree/neo-tree.nvim",

	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},

	config = function()
		local neotree = require("neo-tree")

		neotree.setup({
			event_handlers = {
				{
					event = "file_opened",
					handler = function(_)
						require("neo-tree").close_all()
					end,
				},
			},
		})

		vim.keymap.set("n", "<Leader>m", function()
            vim.cmd("Neotree reveal")
		end)

		vim.keymap.set("n", "<Leader>d", function()
			vim.cmd("Neotree filesystem reveal left")
		end)
	end,
}
