return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	lazy = false,

	opts = {
		ensure_installed = { "markdown", "markdown_inline", "html", "latex", "typst", "yaml" },
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
	},
}
