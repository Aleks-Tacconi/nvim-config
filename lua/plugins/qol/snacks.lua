---snacks.nvim: nicer vim.ui.input and vim.ui.select (e.g. Molten kernel picker).
return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		input = {},
		picker = {},
	},
}
