return {
	"folke/tokyonight.nvim",

	priority = 1000,
	init = function()
		require("tokyonight").setup({
			style = "night",
			transparent = false, -- required to set a solid bg color
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "transparent",
				floats = "transparent",
			},
			sidebars = { "qf", "help", "neo-tree", "bufferline" },
			day_brightness = 0.3,
			hide_inactive_statusline = false,
			dim_inactive = false,
		})

		vim.cmd.colorscheme("tokyonight-night")

		vim.cmd("highlight Normal guibg=#0e0e0e")
		vim.cmd("highlight NormalNC guibg=#0e0e0e")
		vim.cmd("highlight SignColumn guibg=#0e0e0e")
		vim.cmd("highlight MsgArea guibg=#0e0e0e")
		vim.cmd("highlight TelescopeNormal guibg=#0e0e0e")
	end,
}
