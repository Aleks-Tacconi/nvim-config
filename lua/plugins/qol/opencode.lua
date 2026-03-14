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
			"<leader>oa",
			function()
				require("opencode").ask("@this: ", { submit = true })
			end,
			desc = "Ask opencode about selection",
			mode = { "n", "x" },
		},
		{
			"<leader>oe",
			function()
				require("opencode").select()
			end,
			desc = "Open opencode actions",
			mode = { "n", "x" },
		},
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
			mode = "x",
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
			"<leader>oi",
			function()
				require("opencode").command("session.interrupt")
			end,
			desc = "Interrupt opencode session",
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
		local opencode_cmd = "opencode --port"
		local terminal_opts = {
			win = {
				position = "right",
				enter = false,
				on_win = function(win)
					require("opencode.terminal").setup(win.win)
				end,
			},
		}

		vim.g.opencode_opts = {
			server = {
				start = function()
					require("snacks.terminal").open(opencode_cmd, terminal_opts)
				end,
				stop = function()
					local terminal = require("snacks.terminal").get(opencode_cmd, terminal_opts)
					if terminal ~= nil then
						terminal:close()
					end
				end,
				toggle = function()
					require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
				end,
			},
			ask = {
				prompt = "Ask opencode: ",
			},
			select = {
				prompt = "opencode actions: ",
			},
			events = {
				enabled = true,
				reload = true,
			},
		}
	end,
}
