---Configure asynchronous linters per filetype using `nvim-lint`.
return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			c = { "cpplint" },
			cpp = { "cpplint" },
			css = { "stylelint" },
			scss = { "stylelint" },
			less = { "stylelint" },
			dockerfile = { "hadolint" },
			go = { "golangcilint" },
			html = { "htmlhint" },
			htmldjango = { "htmlhint" },
			javascript = { "oxlint" },
			javascriptreact = { "oxlint" },
			typescript = { "oxlint" },
			typescriptreact = { "oxlint" },
			kotlin = { "ktlint" },
			sql = { "sqlfluff" },
		}

		lint.linters.sqlfluff.args = { "lint", "--format=json", "--dialect", "postgres", "-" }

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				if vim.bo.buftype == "" and lint.linters_by_ft[vim.bo.filetype] then
					lint.try_lint()
				end
			end,
		})
	end,
}
