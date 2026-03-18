return {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    config = function()
        require("scrollbar").setup({
            handle = {
                color = "#444444",
            },
            handlers = {
                cursor = false,
            },
        })
    end,
}
