return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters_by_ft.markdown = {}
		lint.linters_by_ft.text = {}
		lint.linters_by_ft.rst = {}

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				local ft = vim.bo.filetype

				if lint.linters_by_ft[ft] then
					lint.try_lint()
				end
			end,
		})
	end,
}
