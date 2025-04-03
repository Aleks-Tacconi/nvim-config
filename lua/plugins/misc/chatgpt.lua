return {
	"jackMort/ChatGPT.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("chatgpt").setup()

		vim.api.nvim_set_keymap("n", "<leader>o", [[:lua ShowOptions()<CR>]], { noremap = true, silent = true })
		vim.api.nvim_set_keymap("v", "<leader>o", [[:lua ShowOptions()<CR>]], { noremap = true, silent = true })

		function ShowOptions()
			local words = {
				"explain_code",
				"complete_code",
				"optimize_code",
				"summarize",
				"fix_bugs",
				"code_readability_analysis",
                "docstring",
                "add_tests"
			}
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			pickers
				.new({}, {
					finder = finders.new_table(words),
					sorter = conf.generic_sorter(opts),
					attach_mappings = function(bufnr, map)
						actions.select_default:replace(function()
							actions.close(bufnr)
							local selection = action_state.get_selected_entry()
							vim.cmd("ChatGPTRun " .. selection[1])
						end)

						map("i", "<C-j>", next_color)
						map("i", "<C-k>", prev_color)
						map("i", "<C-n>", next_color)
						map("i", "<C-p>", prev_color)

						return true
					end,
				})
				:find()
		end
	end,
}
