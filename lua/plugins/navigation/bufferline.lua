return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "ThePrimeagen/harpoon" },
	config = function()
		local harpoon = require("harpoon")

		require("bufferline").setup({
			options = {
				mode = "buffers",
				indicator = { style = "none" },
				separator_style = "thin",
				show_close_icon = false,
				show_buffer_close_icons = false,
				always_show_bufferline = true,
				color_icons = true,
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
				buffer_selected = {
					italic = true,
					bold = true,
                    fg="#ffffff",
				},
				numbers_selected = {
					bold = true,
					italic = false,
                    fg="#ffffff",
				},
			},
		})
		vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "#0e0e0e" })
		vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = "#0e0e0e" })
		vim.api.nvim_set_hl(0, "BufferLineSeparator", { bg = "#0e0e0e", fg = "#0e0e0e" })
		vim.api.nvim_set_hl(0, "BufferLineSeparatorVisible", { bg = "#0e0e0e", fg = "#0e0e0e" })
		vim.api.nvim_set_hl(0, "BufferLineSeparatorSelected", { bg = "#0e0e0e", fg = "#0e0e0e" })
        vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { bg = "#0e0e0e", fg = "#0e0e0e" })
	end,
}
