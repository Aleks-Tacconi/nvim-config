return {
	"nickjvandyke/opencode.nvim",
	lazy = false,
	version = "*",
	dependencies = {
		{
			"folke/snacks.nvim",
			opts = {
				input = {},
				picker = {
					actions = {
						opencode_send = function(...)
							return require("opencode").snacks_picker_send(...)
						end,
					},
					win = {
						input = {
							keys = {
								["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
							},
						},
					},
				},
			},
		},
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>or",
			function()
				require("utils.opencode").send_current_line()
			end,
			desc = "Send current line to opencode",
			mode = "n",
		},
		{
			"<leader>or",
			function()
				require("utils.opencode").send_visual_lines()
			end,
			desc = "Send selected lines to opencode",
			mode = "v",
		},
		{
			"<leader>op",
			function()
				require("utils.opencode").send_current_line_diagnostics()
			end,
			desc = "Send current line diagnostics to opencode",
			mode = "n",
		},
		{
			"<leader>ot",
			function()
				require("utils.opencode").ensure_tmux_pane()
			end,
			desc = "Open tmux opencode pane",
		},
	},
	config = function()
		vim.g.opencode_opts = {
			-- Reuse an existing `opencode --port` server instead of managing one in Neovim.
			server = {
				start = false,
				stop = false,
				toggle = false,
			},
			ask = {
				prompt = "Ask opencode: ",
			},
			select = {
				prompt = "opencode actions: ",
				sections = {
					server = false,
				},
			},
			events = {
				enabled = true,
				reload = true,
			},
		}
	end,
}
