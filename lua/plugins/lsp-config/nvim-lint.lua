return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- NOTE: to use eslint_d you need to create a config using: npx eslint --init

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			lua = { "luacheck" },
			markdown = { "markdownlint" },
			java = { "checkstyle" },
			html = { "markuplint" },
			css = { "stylelint" },
		}

        local pylint_path = vim.fn.getcwd() .. "/venv/bin/pylint"

        if vim.fn.filereadable(pylint_path) == 1 then
            lint.linters.pylint.cmd = pylint_path
        end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		lint.linters.checkstyle.args = {
			"-c",
			"sun_checks.xml",
		}

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
