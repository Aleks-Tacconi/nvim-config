return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- NOTE: to use eslint_d you need to create a config using: npx eslint --init
		local enabled_linters = {
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

		local lint_enabled = false

		lint.linters_by_ft = vim.deepcopy(enabled_linters)
		local lint_ns = lint.get_namespace("pylint")

		vim.keymap.set("n", "<leader>tl", function()
			lint_enabled = not lint_enabled
			if lint_enabled then
				lint.linters_by_ft = vim.deepcopy(enabled_linters)
				vim.cmd("w")
				print("Linting enabled")
			else
				lint.linters_by_ft = {}

				for _, linters in pairs(enabled_linters) do
					local first_linter = linters[1]
					if first_linter then
						local ns = lint.get_namespace(first_linter)
						vim.diagnostic.reset(ns, 0)
					end
				end

				print("Linting disabled")
			end
		end, { desc = "Toggle All Linters" })

		local pylint_path = vim.fn.getcwd() .. "/venv/bin/pylint"

		local poetry_venv = vim.fn.trim(vim.fn.system("poetry env info -p"))
		local poetry_pylint_path = poetry_venv .. "/bin/pylint"

		if vim.fn.filereadable(poetry_pylint_path) == 1 then
			lint.linters.pylint.cmd = poetry_pylint_path
		elseif vim.fn.filereadable(venv_pylint_path) == 1 then
			lint.linters.pylint.cmd = venv_pylint_path
		else
			lint.linters.pylint.cmd = "/bin/pylint"
		end

		lint.linters.checkstyle.args = {
			"-c",
			"sun_checks.xml",
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
