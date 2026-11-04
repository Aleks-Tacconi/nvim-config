return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/ObsidianVault/*.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/ObsidianVault/*.md",
	},

	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "personal",
					path = "~/ObsidianVault/",
				},
			},
			legacy_commands = false,
			frontmatter = { enabled = false },
			ui = {
				enable = false,
				hl_groups = require("rose-pine.plugins.obsidian"),
			},
		})

		vim.keymap.set(
			"n",
			"<leader>sb",
			":Obsidian backlinks<CR>",
			{ noremap = true, silent = true, desc = "Obsidian backlinks" }
		)
		vim.keymap.set(
			"n",
			"<leader>st",
			":Obsidian tags<CR>",
			{ noremap = true, silent = true, desc = "Obsidian tags" }
		)
		vim.keymap.set(
			"n",
			"<leader>gd",
			":Obsidian follow_link<CR>",
			{ noremap = true, silent = true, desc = "Obsidian follow link" }
		)
		vim.keymap.set(
			"n",
			"<leader>o",
			":Obsidian open<CR>",
			{ noremap = true, silent = true, desc = "Obsidian open" }
		)
	end,
}
