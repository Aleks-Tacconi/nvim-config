---Provide pickers, dialogs, notifications, and LazyGit.
return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	keys = {
		{
			"<leader>lg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Open LazyGit",
		},
		{
			"<leader>sf",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find files",
		},
		{
			"<leader>sg",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>sd",
			function()
				require("snacks").picker.diagnostics()
			end,
			desc = "Search diagnostics",
		},
	},
	opts = {
		input = {},
		lazygit = {
			win = { width = 0, height = 0, border = "none" },
		},
		notifier = { enabled = true },
		picker = {
			prompt = " ",
            frecency = true,
			layout = {
				preset = "ivy",
				layout = {
					width = 0,
					height = 0,
					row = 0,
					border = { "", "", "", "", "", "", "", " " },
				},
				---Remove the filename title from the side-by-side preview.
				config = function(layout)
					layout.layout[2][2].title = ""
				end,
			},
			sources = {
				diagnostics = { filter = { cwd = false } },
			},
		},
	},
}
