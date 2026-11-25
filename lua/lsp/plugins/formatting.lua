---Configure formatters per filetype using `conform.nvim`.
return {
	"stevearc/conform.nvim",
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
	opts = function()
		local utils = require("utils.lsp")
		local function ruff_path(_, ctx)
			return utils.get_path("ruff", ctx and ctx.filename)
		end

		return {
			notify_on_error = false,
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				go = { "gofmt" },
				html = { "prettier" },
				htmldjango = { "prettier" },
				javascript = { "oxfmt" },
				javascriptreact = { "oxfmt" },
				typescript = { "oxfmt" },
				typescriptreact = { "oxfmt" },
				json = { "prettier" },
				jsonc = { "prettier" },
				kotlin = { "ktlint" },
				lua = { "stylua" },
				markdown = { "prettier_markdown", "injected" },
				nix = { "nixfmt" },
				python = { "ruff_organize_imports", "ruff_format" },
				qml = { "qmlformat" },
				rust = { "rustfmt" },
				sql = { "pg_format" },
			},
			formatters = {
				ruff_organize_imports = { command = ruff_path },
				ruff_format = { command = ruff_path },
				prettier = {
					prepend_args = { "--tab-width", "2", "--print-width", "100" },
				},
				prettier_markdown = function()
					return vim.tbl_deep_extend("force", require("conform.formatters.prettier"), {
						prepend_args = function(_, ctx)
							local tab_width = vim.endswith(ctx.filename or "", ".ipynb") and "4" or "2"
							return { "--tab-width", tab_width, "--print-width", "300" }
						end,
						options = {
							ft_parsers = {
								markdown = "markdown",
							},
							ext_parsers = {
								ipynb = "markdown",
								md = "markdown",
							},
						},
					})
				end,
			},
		}
	end,
}
