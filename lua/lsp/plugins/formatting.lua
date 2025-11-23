return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({
					async = true,
					lsp_format = "fallback",
				})
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
			prettier_markdown = {
				command = "prettier",
				prepend_args = { "--tab-width", "2", "--print-width", "300" },
			},
			sqlfluff = {
				command = "sqlfluff lint",
				prepend_args = { "--dialect=postgress" },
			},
		},
	},
}
