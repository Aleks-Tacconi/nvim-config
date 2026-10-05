local function harpoon_list()
    return require("harpoon"):list()
end

local function toggle_telescope()
    local harpoon_files = harpoon_list().items
    local file_paths = {}

    for _, item in ipairs(harpoon_files) do
        table.insert(file_paths, item.value)
    end

    require("config.telescope").harpoon_files(file_paths)
end

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        {
            "<leader>H",
            toggle_telescope,
            desc = "Harpoon picker",
        },
        {
            "<leader>h",
            function()
                require("harpoon").ui:toggle_quick_menu(harpoon_list())
            end,
            desc = "Harpoon menu",
        },
        {
            "<leader>a",
            function()
                local harpoon = require("harpoon")
                harpoon_list():add()
                harpoon.ui:toggle_quick_menu(harpoon_list())
                harpoon.ui:toggle_quick_menu(harpoon_list())
            end,
            desc = "Harpoon add file",
        },
        {
            "<leader>1",
            function()
                harpoon_list():select(1)
            end,
            desc = "Harpoon file 1",
        },
        {
            "<leader>2",
            function()
                harpoon_list():select(2)
            end,
            desc = "Harpoon file 2",
        },
        {
            "<leader>3",
            function()
                harpoon_list():select(3)
            end,
            desc = "Harpoon file 3",
        },
        {
            "<leader>4",
            function()
                harpoon_list():select(4)
            end,
            desc = "Harpoon file 4",
        },
        {
            "<leader>5",
            function()
                harpoon_list():select(5)
            end,
            desc = "Harpoon file 5",
        },
        {
            "<leader>6",
            function()
                harpoon_list():select(6)
            end,
            desc = "Harpoon file 6",
        },
        {
            "<leader>7",
            function()
                harpoon_list():select(7)
            end,
            desc = "Harpoon file 7",
        },
        {
            "<leader>8",
            function()
                harpoon_list():select(8)
            end,
            desc = "Harpoon file 8",
        },
    },

    config = function()
        local harpoon = require("harpoon")
        harpoon:setup({
            settings = {
                save_on_toggle = true,
            },
        })
    end,
}
