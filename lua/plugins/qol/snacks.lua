---Provide pickers, dialogs, and notifications.
return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	keys = {
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
		notifier = { enabled = true },
		picker = {
			prompt = " ",
            frecency = true,
			layout = {
				preset = "ivy",
				layout = {
					width = 0.8,
					height = 0.9,
					border = { "┌", "─", "┐", "│", "", "", "", "│" },
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
