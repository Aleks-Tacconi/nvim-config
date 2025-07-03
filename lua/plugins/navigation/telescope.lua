return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local actions = require("telescope.actions")
		local utils = require("utils.telescope")

		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
				prompt_prefix = "   Search: ",
				entry_prefix = " ",
				selection_caret = " ",
			},
			pickers = {
				find_files = utils.picker_theme,
				live_grep = utils.picker_theme,
				diagnostics = utils.picker_theme,
				lsp_references = utils.picker_theme,
				lsp_definitions = utils.picker_theme,
				lsp_implementations = utils.picker_theme,
				lsp_document_symbols = utils.picker_theme,
				lsp_workspace_symbols = utils.picker_theme,
			},
		})
	end,
}
