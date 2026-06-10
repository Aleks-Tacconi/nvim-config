return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		require("config.compat").patch_nvim_treesitter_query_predicates()
	end,

	opts = {
		ensure_installed = { "markdown", "markdown_inline", "html", "latex", "typst", "yaml" },
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true, disable = { "tsx", "typescript" } },
		textobjects = {
			move = {
				enable = true,
				set_jumps = false,
				goto_next_start = {
					["]b"] = { query = "@code_cell.inner", desc = "next code block" },
				},
				goto_previous_start = {
					["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
				},
			},
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["ib"] = { query = "@code_cell.inner", desc = "in block" },
					["ab"] = { query = "@code_cell.outer", desc = "around block" },
				},
			},
			swap = {
				enable = true,
				swap_next = { ["<leader>sbl"] = "@code_cell.outer" },
				swap_previous = { ["<leader>sbh"] = "@code_cell.outer" },
			},
		},
	},
}
