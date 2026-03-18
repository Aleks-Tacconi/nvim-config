return {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 10000,
    config = function()
        require("rose-pine").setup({
            disable_background = true,
        })
        vim.cmd("colorscheme rose-pine-moon")

        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg="grey" })
        vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none", fg = "grey" })
        vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })

        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "none" })

        vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "none", fg = "grey" })
        vim.api.nvim_set_hl(0, "BlinkCmpDocCursorLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "none", fg = "grey" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuCursorLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { bg = "none", fg = "grey" })

        vim.api.nvim_set_hl(0, "LspFloatWinNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "LspFloatWinBorder", { bg = "none", fg = "grey" })
        vim.api.nvim_set_hl(0, "LspHover", { bg = "none" })
        vim.api.nvim_set_hl(0, "LspHoverBorder", { bg = "none", fg = "grey" })
        vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { bg = "none" })

        vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1a1a1a" })
    end,
}
