---Review unified Git diffs using native buffers and the shared picker.

---Ensure `<Esc>` and `q` exit DeltaView even when the cursor is on a removed line or header.
local function patch_exit_strategy()
	local view = require("deltaview.view")
	if view._patched_exit then
		return
	end
	view._patched_exit = true

	local orig = view.get_delta_buffer_cursor_exit_strategy
	view.get_delta_buffer_cursor_exit_strategy = function(bufnr, winnr, alternative_bufnr)
		local strategy = orig(bufnr, winnr, alternative_bufnr)
		return function()
			if view.cursor_placement ~= nil then
				return strategy()
			end

			local diff_set = vim.b[bufnr].delta_diff_data_set or {}
			local cur_row = vim.api.nvim_win_get_cursor(0)[1]
			local best, best_dist

			for _, diff_data in ipairs(diff_set) do
				for _, hunk in ipairs(diff_data.hunks or {}) do
					for _, line in ipairs(hunk.lines or {}) do
						local lnum = line.new_line_num or line.old_line_num
						if lnum then
							local row = line.formatted_diff_line_num + 1
							local dist = math.abs(row - cur_row)
							if not best_dist or dist < best_dist then
								best_dist = dist
								best = {
									winnr = winnr,
									cursor = { lnum, 0 },
									filepath = diff_data.new_path or diff_data.old_path,
								}
							end
						end
					end
				end
			end

			if best then
				view.cursor_placement = best
				return strategy()
			end

			if alternative_bufnr and vim.api.nvim_buf_is_valid(alternative_bufnr) then
				vim.api.nvim_set_current_buf(alternative_bufnr)
				return true
			end
			return false
		end
	end
end

return {
	"kokusenz/deltaview.nvim",
	cmd = { "DeltaView", "DeltaMenu", "Delta" },
	keys = {
		{ "<leader>v", "<cmd>DeltaView<cr>", desc = "View file diff" },
	},
	opts = {
		fzf_picker = "ui_select",
		keyconfig = {
			dv_toggle_keybind = "",
			dm_toggle_keybind = "",
			d_toggle_keybind = "",
		},
	},
	config = function(_, opts)
		require("deltaview").setup(opts)
		patch_exit_strategy()
	end,
}
