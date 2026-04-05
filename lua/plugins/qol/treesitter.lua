return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		require("config.compat").patch_nvim_treesitter_query_predicates()
	end,

	opts = {
		ensure_installed = { "markdown", "markdown_inline", "html", "latex", "typst", "yaml" },
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true, disable = { "tsx", "typescript" } },
	},
}
