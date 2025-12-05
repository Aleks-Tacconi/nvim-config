return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	init = function()
		local rose_pine_lualine = {
			normal = {
				a = { fg = "#393552", bg = "#EA9A97", gui = "bold" },
				b = { fg = "#EA9A97", bg = "#393552" },
				c = { fg = "#cccccc", bg = "#1A1A1A" },
			},
			insert = {
				a = { fg = "#393552", bg = "#9CCFD8", gui = "bold" },
				b = { fg = "#9CCFD8", bg = "#393552" },
				c = { fg = "#cccccc", bg = "#1A1A1A" },
			},
			visual = {
				a = { fg = "#393552", bg = "#C4A7E7", gui = "bold" },
				b = { fg = "#C4A7E7", bg = "#393552" },
				c = { fg = "#cccccc", bg = "#1A1A1A" },
			},
			command = {
				a = { fg = "#393552", bg = "#C4A7E7", gui = "bold" },
				b = { fg = "#C4A7E7", bg = "#393552" },
				c = { fg = "#cccccc", bg = "#1A1A1A" },
			},
		}

		require("lualine").setup({
			options = {
				ignore_focus = { "neo-tree" },
				icons_enabled = true,
				theme = rose_pine_lualine,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				always_divide_middle = true,
				always_show_tabline = true,
				globalstatus = true,
				refresh = {
					statusline = 100,
					tabline = 100,
					winbar = 100,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "diagnostics" },
				lualine_c = {
					function()
						return "https://github.com/Aleks-Tacconi :)"
					end,
				},
				lualine_x = {},
				lualine_y = { "branch" },
				lualine_z = { "progress" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			winbar = {},
			tabline = {
				lualine_a = {
					"hostname",
				},
				lualine_b = {
					function()
						return ""
					end,
				},
				lualine_c = {
					function()
						local file_path = vim.fn.expand("%:p")
						return file_path:gsub("/", " » "):gsub("^ » ", "")
					end,
				},
			},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
