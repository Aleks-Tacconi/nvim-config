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

	keys = { { "<Leader>nt", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" } },
	cmd = { "Neotest" },

	config = function()
		local utils = require("utils.lsp")
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					python = utils.get_path("python"),
				}),
				require("neotest-java")({}),
			},
		})
	end,
}
