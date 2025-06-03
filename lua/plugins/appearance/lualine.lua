return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local colors = {
			ivoryMist = "#F8F8F0",
			samuraiRed = "#E82424",
			hazardOrange = "#FF9E3B",
			mutedTeal = "#3BA7A4",
		}

		local function diag_count(severity)
			return #vim.diagnostic.get(0, { severity = severity })
		end

		require("lualine").setup({
			options = {
				component_separators = " ",
				section_separators = { left = " ", right = " " },
				theme = {
					normal = {
						a = { fg = colors.ivoryMist, bg = "NONE" },
						b = { fg = colors.ivoryMist, bg = "NONE" },
						c = { fg = colors.ivoryMist, bg = "NONE" },
						z = { fg = colors.ivoryMist, bg = "NONE" },
					},
					insert = { a = { fg = colors.ivoryMist, bg = "NONE" } },
					visual = { a = { fg = colors.ivoryMist, bg = "NONE" } },
					replace = { a = { fg = colors.ivoryMist, bg = "NONE" } },
					command = { a = { fg = colors.ivoryMist, bg = "NONE" } },
					inactive = {
						a = { fg = colors.ivoryMist, bg = "NONE" },
						b = { fg = colors.ivoryMist, bg = "NONE" },
						c = { fg = colors.ivoryMist, bg = "NONE" },
						z = { fg = colors.ivoryMist, bg = "NONE" },
					},
				},
				icons_enabled = true,
				disabled_filetypes = {},
				globalstatus = true,
			},

			sections = {
				lualine_a = {},
				lualine_b = {
					{
						function()
							return " "
						end,
						cond = function()
							return diag_count(vim.diagnostic.severity.ERROR) > 0
								or diag_count(vim.diagnostic.severity.WARN) > 0
								or diag_count(vim.diagnostic.severity.INFO) > 0
						end,
						color = { bg = "NONE", fg = "NONE" },
						padding = { left = 0, right = 0 },
					},
					-- error count element
					{
						function()
							return "󰅚 " .. diag_count(vim.diagnostic.severity.ERROR)
						end,
						cond = function()
							return diag_count(vim.diagnostic.severity.ERROR) > 0
						end,
						color = function()
							return { fg = colors.samuraiRed, bg = "NONE" }
						end,
						padding = { left = 0, right = 0 },
					},

					-- warning count element
					{
						function()
							local n = diag_count(vim.diagnostic.severity.WARN)
							return "󰀪 " .. n
						end,
						cond = function()
							return diag_count(vim.diagnostic.severity.WARN) > 0
						end,
						color = function()
							local n = diag_count(vim.diagnostic.severity.WARN)
							return { fg = colors.hazardOrange, bg = "NONE" }
						end,
						padding = { left = 0, right = 0 },
					},

					-- info count element
					{
						function()
							return "󰋽 " .. diag_count(vim.diagnostic.severity.INFO)
						end,
						cond = function()
							return diag_count(vim.diagnostic.severity.INFO) > 0
						end,
						color = function()
							return { fg = colors.mutedTeal, bg = "NONE" }
						end,
						padding = { left = 0, right = 0 },
					},

					-- filename element
					{
						"filename",
						file_status = false,
						path = 1,
						color = { fg = colors.ivoryMist, bg = "NONE" },
						fmt = function(str)
							return str ~= "" and str or "[No Name]"
						end,
						padding = { left = 1, right = 0 },
					},

					-- if file is modified show plus sign [+]
					{
						function()
							return vim.bo.modified and "[+]" or ""
						end,
						color = { fg = colors.hazardOrange, bg = "NONE", gui = "bold" },
						cond = function()
							return vim.bo.modified
						end,
						padding = { left = 1, right = 0 },
					},
				},

				lualine_c = {},
				lualine_x = {},
				lualine_y = {
					{
						"filetype",
						colored = true,
						icon_only = false,
						color = { fg = colors.ivoryMist, bg = "NONE" },
					},
				},

				lualine_z = {
					{ "%l:%c", color = { fg = colors.ivoryMist, bg = "NONE" } },
					{ "%p%%/%L", color = { fg = colors.ivoryMist, bg = "NONE" }, padding = { left = 0, right = 1 } },
				},
			},
		})
	end,
}
