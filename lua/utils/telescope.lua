local M = {}

M.picker_theme = {
    prompt_title = "",
    results_title = "",
    preview_title = {},
    get_status_text = function()
        return ""
    end,
    sorting_strategy = "ascending",
    layout_config = {
        prompt_position = "top",
        preview_width = 0.6,
        width = 0.8,
        height = 0.8,
    },
}

return M
