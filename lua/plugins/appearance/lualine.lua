return {
	"nvim-lualine/lualine.nvim",
	opts = function()
		vim.opt.showmode = false
		vim.opt.fillchars:append({ stl = "━", stlnc = "━" })

		local icons = {
			neovim = " ",
			git = { branch = " " },
		}

		local function get_lualine_theme()
			local theme = {}

			for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command" }) do
				theme[mode] = {
					a = { bg = "#333333", fg = "#f8f8f2", gui = "bold" },
					b = { bg = "#2a2a2a", fg = "NONE" },
					c = { bg = "NONE", fg = "NONE", gui = "bold" },
					y = { bg = "#2a2a2a", },
				}
			end

			return theme
		end

		return {
			options = {
				globalstatus = vim.o.laststatus == 3,
				component_separators = "",
				section_separators = { left = "", right = "" },
				theme = get_lualine_theme(),
			},
			sections = {
				lualine_a = {
					{
						"mode",
						icon = icons.neovim,
						separator = { left = "", right = "" },
						padding = { left = 1, right = 1 },
					},
				},
				lualine_b = {
					{
						"branch",
						icon = icons.git.branch,
						separator = { left = "", right = "" },
					},
				},
				lualine_c = {
					{ "%=", padding = 0 },
					{
						"filename",
						path = 1,
						icon = "",
						separator = { left = "", right = "██" },
						padding = 0,
						color = function()
							return "lualine_a_normal"
						end,
					},
				},
				lualine_x = {},
				lualine_y = {
                    {
                        "filetype",
						separator = { left = "", right = "" },
						padding = { left = 1, right = 2 },
                    }
                },
				lualine_z = {
					{
						function()
							local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
							local max = vim.api.nvim_buf_line_count(0)
							local percent = (lnum == 1 and "TOP")
								or (lnum == max and "BOT")
								or string.format("%2d%%%%", math.floor(100 * lnum / max))
							return string.format("%" .. string.len(vim.bo.textwidth) .. "d %s", col + 1, percent)
						end,
						separator = { left = "", right = "" },
						padding = { left = 1, right = 1 },
					},
				},
			},
		}
	end,
}
