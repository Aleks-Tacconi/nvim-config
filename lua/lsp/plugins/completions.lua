---Configure completion appearance and explicit editing shortcuts.
return {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
        keymap = {
            preset = "none",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-y>"] = { "accept", "fallback" },
            ["<C-e>"] = { "cancel", "fallback" },
            ["<Tab>"] = { "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
        },
        completion = {
            trigger = {
                show_on_insert = true,
                show_on_backspace = true,
                show_on_blocked_trigger_characters = {},
            },
            documentation = {
                window = {
                    border = "single",
                },
            },
            ghost_text = { enabled = true, show_without_selection = true },
            menu = {
                border = "single",
                draw = {
                    columns = {
                        { "kind_icon", "kind", gap = 1 },
                        { "label", "label_description", gap = 3 },
                        { "source_name" },
                    },
                    components = {
                        label = {
                            text = function(ctx)
                                return "│ " .. ctx.label
                            end,
                        },
                    },
                },
            },
        },
    },
}
