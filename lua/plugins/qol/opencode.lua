return {
	"sudo-tee/opencode.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MeanderingProgrammer/render-markdown.nvim",
		"saghen/blink.cmp",
		"nvim-telescope/telescope.nvim",
	},
	opts = {
		ui = {
			position = "float",
			window_width = 1.0,
			input_height = 0.3,
			window_highlight = "Normal:OpencodeBackground,FloatBorder:OpencodeBorder",
		},
		keymap = {
			editor = {
				["<leader>ot"] = { "toggle" },
			},
		},
	},
}
