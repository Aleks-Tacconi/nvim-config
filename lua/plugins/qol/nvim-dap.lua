return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "mfussenegger/nvim-dap-python",
        { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        {
            "<leader>wa",
            function()
                require("dapui").elements.watches.add()
            end,
            desc = "DAP watch add",
            mode = "n",
        },
        {
            "<leader>wa",
            function()
                require("dapui").elements.watches.add(vim.fn.expand("<cword>"))
            end,
            desc = "DAP watch add word",
            mode = "x",
        },
        {
            "<leader>wd",
            function()
                require("dapui").elements.watches.remove()
            end,
            desc = "DAP watch remove",
        },
        {
            "<leader>bt",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Toggle breakpoint",
        },
        {
            "<leader>b1",
            function()
                require("dap").continue()
            end,
            desc = "DAP continue",
        },
        {
            "<leader>b2",
            function()
                require("dap").step_into()
            end,
            desc = "DAP step into",
        },
        {
            "<leader>b3",
            function()
                require("dap").step_over()
            end,
            desc = "DAP step over",
        },
        {
            "<leader>b4",
            function()
                require("dap").step_out()
            end,
            desc = "DAP step out",
        },
        {
            "<leader>b5",
            function()
                require("dap").step_back()
            end,
            desc = "DAP step back",
        },
        {
            "<leader>b6",
            function()
                require("dap").restart()
            end,
            desc = "DAP restart",
        },
        {
            "<leader>b7",
            function()
                require("dap").terminate()
            end,
            desc = "DAP terminate",
        },
        {
            "<leader>b8",
            function()
                require("dap").disconnect()
            end,
            desc = "DAP disconnect",
        },
        {
            "<leader>b9",
            function()
                local dap = require("dap")
                dap.terminate()
                require("dapui").close()
            end,
            desc = "DAP close",
        },
        {
            "<leader>bs",
            function()
                require("config.telescope").debug_actions()
            end,
            desc = "Debug session picker",
        },
    },
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    config = function()
        require("lazydev").setup({
            library = { "nvim-dap-ui" },
        })
        require("config.dap.ui").setup()
        require("config.dap.python").setup()
        require("config.dap.cpp").setup()
    end,
}
