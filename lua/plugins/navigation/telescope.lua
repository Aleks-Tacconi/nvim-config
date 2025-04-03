return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("telescope").setup({
			pickers = {
				find_files = {
					previewer = true,
					follow = true,
				},
				live_grep = {
					previewer = true,
					follow = true,
				},
			},
			defaults = {
				file_ignore_patterns = { "venv/*" },
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>sf", builtin.find_files)
		vim.keymap.set("n", "<leader>sg", builtin.live_grep)
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics)
	end,
}
