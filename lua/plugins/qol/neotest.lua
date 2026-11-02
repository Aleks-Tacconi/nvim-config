return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-neotest/neotest-python",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	keys = { { "<Leader>nt", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" } },
	cmd = { "Neotest" },

	config = function()
		local utils = require("utils.lsp")
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					python = utils.get_path("python"),
				}),
			},
		})
	end,
}
