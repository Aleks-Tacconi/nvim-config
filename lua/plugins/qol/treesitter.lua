---Use native Treesitter highlighting with the current parser and textobject APIs.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			opts = { move = { set_jumps = false }, select = { lookahead = true } },
		},
	},
	config = function()
		require("config.treesitter").setup()
	end,
}
