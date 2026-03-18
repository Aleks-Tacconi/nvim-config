return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},

		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "right_align", -- or "eol"
			delay = 400,
			ignore_whitespace = false,
		},
		current_line_blame_formatter = " <summary> • <author> • <author_time:%m-%d-%Y %H:%M:%S>",
	},
}
