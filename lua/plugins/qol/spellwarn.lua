return {
    "ravibrock/spellwarn.nvim",
    event = "VeryLazy",
    config = function()
        require("spellwarn").setup({

            event = {
                "InsertLeave",
                "TextChanged",
                "TextChangedI",
                "TextChangedP",
            },
            enable = true,
            ft_config = {
                markdown = true,
                txt = true,
            },
            ft_default = false,
            max_file_size = nil,
            severity = {
                spellbad = "WARN",
                spellcap = "HINT",
                spelllocal = "HINT",
                spellrare = "INFO",
            },
            suggest = false,
            prefix = "[spellwarn] ",
            diagnostic_opts = { severity_sort = true },
        })
    end,
}
