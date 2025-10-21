return {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    config = function()
        require("markdown").setup({
            mappings = {
                inline_surround_toggle = "<leader>",
                inline_surround_toggle_line = false,
                inline_surround_delete = false,
                inline_surround_change = false,
                link_add = false,
                link_follow = false,
                go_curr_heading = false,
                go_parent_heading = false,
                go_next_heading = false,
                go_prev_heading = false,
            },
            inline_surround = {
                emphasis = {
                    key = "i",
                    txt = "*",
                },
                strong = {
                    key = "b",
                    txt = "**",
                },
                strikethrough = {
                    key = "s",
                    txt = "~~",
                },
                code = {
                    key = "c",
                    txt = "`",
                },
            },
            link = {
                paste = {
                    enable = true,
                },
            },
        }
)
    end,
}
