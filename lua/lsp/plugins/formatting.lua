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
			desc = "Format file",
		},
	},
	opts = {
		notify_on_error = false,
		formatters = {
			prettier = {
				prepend_args = { "--tab-width", "2", "--print-width", "100" },
			},
			prettier_markdown = {
				command = "prettier",
				prepend_args = { "--tab-width", "2", "--print-width", "300" },
			},
			sqlfluff = {
				command = "sqlfluff lint",
				prepend_args = { "--dialect=postgress" },
			},
			swipl_fmt = {
				command = "swipl",
				stdin = false,
				args = {
					"-q",
					"-g",
					"use_module(library(prolog_format))",
					"-g",
					"prolog_format:format_file('$FILENAME')",
					"-t",
					"halt",
				},
				tempfile_postfix = ".pl",
			},
		},
	},
}
