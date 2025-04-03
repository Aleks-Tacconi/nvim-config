return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "ThePrimeagen/harpoon" },
	config = function()
		local harpoon = require("harpoon")

		require("bufferline").setup({
			options = {
				indicator = {
					style = "none",
				},
				numbers = function(opts)
					local marks = harpoon:list().items
					local bufname = vim.fn.fnamemodify(vim.fn.bufname(opts.id), ":p")

					for i, mark in ipairs(marks) do
						local mark_path = vim.fn.fnamemodify(mark.value, ":p") -- Convert to absolute
						if bufname == mark_path then
							return i
						end
					end

					return -1
				end,
				custom_filter = function(buf_number)
					local marks = harpoon:list().items
					local bufname = vim.fn.fnamemodify(vim.fn.bufname(buf_number), ":p")

					for _, mark in ipairs(marks) do
						local mark_path = vim.fn.fnamemodify(mark.value, ":p") -- Convert to absolute
						if bufname == mark_path then
							return true
						end
					end
					return false
				end,
				sort_by = function(buffer_a, buffer_b)
					local marks = harpoon:list().items
					local bufname_a = vim.fn.fnamemodify(vim.fn.bufname(buffer_a.id), ":p")
					local bufname_b = vim.fn.fnamemodify(vim.fn.bufname(buffer_b.id), ":p")

					local a_index, b_index = 100, 100 -- Default high index
					for i, mark in ipairs(marks) do
						local mark_path = vim.fn.fnamemodify(mark.value, ":p") -- Convert to absolute
						if bufname_a == mark_path then
							a_index = i
						end
						if bufname_b == mark_path then
							b_index = i
						end
					end

					return a_index < b_index
				end,
			},
			highlights = {
				fill = {
					bg = "none",
				},
				background = {
					bg = "none",
				},
				tab = {
					bg = "none",
				},
				tab_selected = {
					bg = "none",
				},
				tab_close = {
					bg = "none",
				},
				buffer_selected = {
					bg = "none",
					bold = true,
					italic = false,
				},
				separator = {
					fg = "#3b4261",
					bg = "none",
				},
				separator_selected = {
					fg = "#3b4261",
					bg = "none",
				},
			},
		})
	end,
}
