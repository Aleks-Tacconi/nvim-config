return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Telescope" },
    keys = {
        {
            "<leader>sf",
            function()
                require("config.telescope").find_files()
            end,
            desc = "Find files",
        },
        {
            "<leader>sg",
            function()
                require("config.telescope").live_grep()
            end,
            desc = "Live grep",
        },
        {
            "<leader>sd",
            function()
                require("config.telescope").diagnostics()
            end,
            desc = "Search diagnostics",
        },
    },
    config = function()
        require("config.telescope").setup()
    end,
}
