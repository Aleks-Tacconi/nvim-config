return {
    "laytan/cloak.nvim",
    event = "BufReadPre",
    config = function()
        require("cloak").setup()
    end,
}
