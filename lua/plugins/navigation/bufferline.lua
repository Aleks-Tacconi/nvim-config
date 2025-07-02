return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", { "ThePrimeagen/harpoon", branch = "harpoon2" } },
	config = function()
		local harpoon = require("harpoon")

		local function numbers(opts)
			local marks = harpoon:list().items
			local bufname = vim.fn.fnamemodify(vim.fn.bufname(opts.id), ":p")

			for i, mark in ipairs(marks) do
				local mark_path = vim.fn.fnamemodify(mark.value, ":p")
				if bufname == mark_path then
					return i
				end
			end

			return -1
		end

		local function custom_filter(buf_number)
			local marks = harpoon:list().items
			local bufname = vim.fn.fnamemodify(vim.fn.bufname(buf_number), ":p")

			for _, mark in ipairs(marks) do
				local mark_path = vim.fn.fnamemodify(mark.value, ":p")
				if bufname == mark_path then
					return true
				end
			end
			return false
		end

		local function sort_by(buffer_a, buffer_b)
			local marks = harpoon:list().items
			local bufname_a = vim.fn.fnamemodify(vim.fn.bufname(buffer_a.id), ":p")
			local bufname_b = vim.fn.fnamemodify(vim.fn.bufname(buffer_b.id), ":p")

			local a_index, b_index = 100, 100
			for i, mark in ipairs(marks) do
				local mark_path = vim.fn.fnamemodify(mark.value, ":p")
				if bufname_a == mark_path then
					a_index = i
				end
				if bufname_b == mark_path then
					b_index = i
				end
			end

			return a_index < b_index
		end

		require("bufferline").setup({
			options = {
				mode = "buffers",
				show_buffer_close_icons = false,
				numbers = numbers,
				separator_style = "slant",
				custom_filter = custom_filter,
				sort_by = sort_by,
			},
			highlights = {
				background = {
					fg = "#cccccc",
				},
				numbers_visible = {
					fg = "#ffffff",
				},
				buffer_visible = {
					fg = "#ffffff",
				},
				buffer_selected = {
					bold = true,
					italic = false,
				},
				numbers = {
					fg = "#cccccc",
				},
				numbers_selected = {
					bold = true,
					italic = false,
				},
			},
		})
	end,
}
