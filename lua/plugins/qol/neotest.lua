local utils = require("utils.lsp")

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		-- require("neotest").setup({
		-- 	adapters = {
		-- 		require("neotest-python")({
		-- 			python = utils.get_path("python"),
		-- 		}),
		-- 		require("neotest-java")({}),
		-- 	},
		-- })
	end,
}
