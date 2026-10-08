local function set_notebook_highlights()
	vim.api.nvim_set_hl(0, "NotebookCellBody", { bg = "#17191f" })
	vim.api.nvim_set_hl(0, "NotebookCellBorder", { bg = "#3a3f4b" })
	vim.api.nvim_set_hl(0, "NotebookCellInfo", { fg = "#6e7681", bg = "none" })
	vim.api.nvim_set_hl(0, "NotebookCellLanguage", { fg = "#a6adc8", bg = "none" })
	vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#17191f" })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "#161616" })
	vim.api.nvim_set_hl(0, "NotebookActiveCellMargin", { fg = "#89b4fa" })
end

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	init = function()
		set_notebook_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_notebook_highlights,
		})
	end,
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		anti_conceal = { enabled = true },
		render_modes = { "n", "c", "t", "i" },
		file_types = { "markdown", "Avante", "copilot-chat" },
		code = {
			disable_background = false,
			border = "thin",
			language = false,
			language_border = "-",
			language_icon = false,
			language_left = " ",
			language_right = " ",
			left_pad = 1,
			right_pad = 1,
			above = "-",
			below = "-",
			highlight = "NotebookCellBody",
			highlight_border = "NotebookCellBorder",
			highlight_info = "NotebookCellInfo",
			highlight_language = "NotebookCellLanguage",
			highlight_fallback = "NotebookCellInfo",
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		set_notebook_highlights()
	end,
	ft = { "markdown", "Avante", "copilot-chat" },
}
