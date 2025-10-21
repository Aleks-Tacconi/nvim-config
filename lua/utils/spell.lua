local M = {}

function M.popup()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local word = vim.fn.expand("<cword>")
	local suggestions = vim.fn.spellsuggest(word)
	if #suggestions == 0 then
		return
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Spelling Suggestions",
			finder = require("telescope.finders").new_table({
				results = suggestions,
			}),
			sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
			attach_mappings = function(prompt_bufnr)
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")
				actions.select_default:replace(function()
					local choice = action_state.get_selected_entry().value
					actions.close(prompt_bufnr)

					local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]

					local new_line = line:gsub("%f[%w]" .. word .. "%f[%W]", choice)
					vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
				end)
				return true
			end,
		})
		:find()
end

return M
