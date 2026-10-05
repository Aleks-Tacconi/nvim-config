return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
        local theme = {
            normal = {
                a = { fg = "#c4a7e7", bg = "none" },
                b = { fg = "#6e6a86", bg = "none" },
                c = { fg = "#e0def4", bg = "none" },
                x = { fg = "#6e6a86", bg = "none" },
                y = { fg = "#6e6a86", bg = "none" },
                z = { fg = "#6e6a86", bg = "none" },
            },
            insert = {
                a = { fg = "#c4a7e7", bg = "none" },
                b = { fg = "#6e6a86", bg = "none" },
                c = { fg = "#e0def4", bg = "none" },
                x = { fg = "#6e6a86", bg = "none" },
                y = { fg = "#6e6a86", bg = "none" },
                z = { fg = "#6e6a86", bg = "none" },
            },
            visual = {
                a = { fg = "#c4a7e7", bg = "none" },
                b = { fg = "#6e6a86", bg = "none" },
                c = { fg = "#e0def4", bg = "none" },
                x = { fg = "#6e6a86", bg = "none" },
                y = { fg = "#6e6a86", bg = "none" },
                z = { fg = "#6e6a86", bg = "none" },
            },
            replace = {
                a = { fg = "#c4a7e7", bg = "none" },
                b = { fg = "#6e6a86", bg = "none" },
                c = { fg = "#e0def4", bg = "none" },
                x = { fg = "#6e6a86", bg = "none" },
                y = { fg = "#6e6a86", bg = "none" },
                z = { fg = "#6e6a86", bg = "none" },
            },
            command = {
                a = { fg = "#c4a7e7", bg = "none" },
                b = { fg = "#6e6a86", bg = "none" },
                c = { fg = "#e0def4", bg = "none" },
                x = { fg = "#6e6a86", bg = "none" },
                y = { fg = "#6e6a86", bg = "none" },
                z = { fg = "#6e6a86", bg = "none" },
            },
            inactive = {
                a = { fg = "#6e6a86", bg = "none" },
                b = { fg = "#6e6a86", bg = "none" },
                c = { fg = "#6e6a86", bg = "none" },
                x = { fg = "#6e6a86", bg = "none" },
                y = { fg = "#6e6a86", bg = "none" },
                z = { fg = "#6e6a86", bg = "none" },
            },
        }

        require("lualine").setup({
            options = {
                component_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = { "dashboard", "lazy" },
                },
                globalstatus = true,
                icons_enabled = true,
                section_separators = { left = "", right = "" },
                theme = theme,
            },
            sections = {
                lualine_a = {
                    { "mode" },
                },
                lualine_b = { "branch", "diff" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "filetype" },
                lualine_y = {},
                lualine_z = {
                    {
                        function()
                            local enc = vim.bo.fileencoding or vim.bo.encoding or "utf-8"
                            local pos = vim.api.nvim_win_get_cursor(0)
                            local line, col = pos[1], pos[2] + 1
                            return enc .. " " .. line .. ":" .. col
                        end,
                    },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { { "filename", path = 1, color = { fg = "#6e6a86" } } },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
        })
    end,
}
