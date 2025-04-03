return {
	"yioneko/nvim-yati",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy",
	config = function()
		require("nvim-treesitter.configs").setup({
			yati = {
				enable = true,
				default_lazy = true,
				default_fallback = "auto",
			},
			indent = { enable = false },
		})
	end,
}
