return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		lint.linters.checkstyle.config_file = vim.fn.expand("~/.config/nvim/checkstyle.xml")

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
