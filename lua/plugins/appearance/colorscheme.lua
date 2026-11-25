return {
	"rose-pine/neovim",
	name = "rose-pine",
	priority = 10000,
	config = function()
		require("rose-pine").setup({
			styles = { transparency = true },
			highlight_groups = {
				FloatBorder = { fg = "muted", bg = "none" },
				BlinkCmpDoc = { bg = "none" },
				BlinkCmpDocBorder = { fg = "muted", bg = "none" },
				BlinkCmpDocCursorLine = { bg = "highlight_low" },
				BlinkCmpMenu = { bg = "none" },
				BlinkCmpMenuBorder = { fg = "muted", bg = "none" },
				BlinkCmpMenuCursorLine = { bg = "highlight_low" },
				BlinkCmpGhostText = { fg = "muted", italic = true },
				BlinkCmpSignatureHelp = { bg = "none" },
				BlinkCmpSignatureHelpBorder = { fg = "muted", bg = "none" },
				CursorLine = { bg = "highlight_low" },
			},
		})
		vim.cmd("colorscheme rose-pine-moon")
	end,
}
