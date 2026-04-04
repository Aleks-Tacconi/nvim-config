return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		anti_conceal = { enabled = true },
		render_modes = { "n", "c", "t", "i" },
		file_types = { "Avante", "copilot-chat", "opencode_output" },
	},
	ft = { "Avante", "copilot-chat", "opencode_output" },
}
