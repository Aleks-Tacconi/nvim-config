return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
		},
	},
	opts = {
		notify_on_error = false,
		formatters = {
			prettier = {
				prepend_args = { "--tab-width", "4", "--print-width", "300" },
			},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = { "prettier" },
			html = { "prettier" },
			htmldjango = { "prettier" },
			css = { "prettier" },
			yaml = { "yamlfmt" },
		},
	},
}
