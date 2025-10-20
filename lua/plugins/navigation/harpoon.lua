return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },

    config = function()
        local harpoon = require("harpoon")
        local conf = require("telescope.config").values
        local utils = require("utils.telescope")

        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            local opts = {
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }
            for k, v in pairs(utils.picker_theme) do
                opts[k] = v
            end
            require("telescope.pickers").new({}, opts):find()
        end

        local function select(n)
            harpoon:list():select(n)
        end

        vim.keymap.set("n", "<leader>H", function()
            vim.o.winborder = "none"
            toggle_telescope(harpoon:list())
        end)

        vim.keymap.set("n", "<leader>h", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end)

        harpoon:setup({
            settings = {
                save_on_toggle = true,
            },
        })

        vim.keymap.set("n", "<leader>a", function()
            harpoon:list():add()
            harpoon.ui:toggle_quick_menu(harpoon:list())
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end)

        for i = 1, 8 do
            vim.keymap.set("n", "<leader>" .. i, function()
                select(i)
            end)
        end
    end,
}
