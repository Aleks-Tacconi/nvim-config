---Configure Markdown and notebook rendering.
local function set_notebook_highlights()
	vim.api.nvim_set_hl(0, "NotebookCellBody", { bg = "#1f1d2e" })
	vim.api.nvim_set_hl(0, "NotebookCellBorder", { bg = "#403d52" })
	vim.api.nvim_set_hl(0, "NotebookCellInfo", { fg = "#6e6a86", bg = "NONE" })
	vim.api.nvim_set_hl(0, "NotebookCellLanguage", { fg = "#9ccfd8", bg = "NONE", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#1f1d2e" })
	vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = "#ebbcba", bg = "#26233a" })
	vim.api.nvim_set_hl(0, "NotebookActiveCellMargin", { fg = "#9ccfd8", bg = "NONE" })
	-- Prevent Molten from painting a second background only behind text tokens in evaluated cells.
	vim.api.nvim_set_hl(0, "MoltenCell", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "MoltenOutputBorder", { fg = "#c4a7e7", bg = "NONE" })
end

return {
	"MeanderingProgrammer/render-markdown.nvim",
	lazy = false,
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
		max_file_size = math.huge,
		anti_conceal = {
			enabled = true,
			ignore = { code_background = true, code_border = true, code_language = true },
		},
		render_modes = { "n", "c", "t", "i" },
		file_types = { "markdown" },
		code = {
			disable_background = false,
			border = "thin",
			language = true,
			language_border = "─",
			language_icon = true,
			language_name = true,
			language_left = " ",
			language_right = " ",
			left_pad = 1,
			right_pad = 1,
			above = "─",
			below = "─",
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
}
