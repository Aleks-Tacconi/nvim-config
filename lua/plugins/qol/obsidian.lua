return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    event = {
        "BufReadPre " .. vim.fn.expand("~") .. "/SecondBrain/*.md",
        "BufNewFile " .. vim.fn.expand("~") .. "/SecondBrain/*.md",
    },

    config = function()
        require("obsidian").setup({
            workspaces = {
                {
                    name = "personal",
                    path = "~/SecondBrain/",
                },
            },
            legacy_commands = false,
            ui = { enable = false },
        })

        vim.keymap.set("n", "<leader>sb", ":Obsidian backlinks<CR>", { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>st", ":Obsidian tags<CR>", { noremap = true, silent = true })
    end,
}
