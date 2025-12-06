local utils = require("utils.lsp")

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-neotest/neotest-python",
		"rcasia/neotest-java",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	-- need to run the following for java:
	-- :NeotestJava setup

	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					python = utils.get_path("python"),
				}),
				require("neotest-java")({}),
			},
		})

		--vim.api.nvim_create_autocmd("BufEnter", {
		--	callback = function()
		--		local status_ok, neotest = pcall(require, "neotest")
		--		if status_ok then
		--			pcall(neotest.summary.open)
		--		end
		--	end,
		--})
		--
		vim.keymap.set("n", "<Leader>nt", function()
			require("neotest").summary.toggle()
		end)
	end,
}
