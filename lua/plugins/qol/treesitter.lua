---Use native Treesitter highlighting with the current parser API.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("config.treesitter").setup()
	end,
}
