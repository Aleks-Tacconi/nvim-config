return {
	"folke/tokyonight.nvim",

	priority = 1000,
	init = function()
		vim.cmd.colorscheme("tokyonight-night")
		require("tokyonight").setup({
			style = "night",
			light_style = "day",
			transparent = true,
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "transparent",
				floats = "transparent",
			},
			sidebars = { "qf", "help", "neo-tree" },
			day_brightness = 0.3,
			hide_inactive_statusline = false,
			dim_inactive = false,
		})
	end,
}
