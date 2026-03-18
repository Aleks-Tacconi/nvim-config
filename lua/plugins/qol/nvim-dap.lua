local function open_debug_picker()
    local dap = require("dap")
    local dapui = require("dapui")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local is_java = vim.bo.filetype == "java"
    local options = is_java and { "Debug Main Application", "Debug Tests" } or { "Continue", "Restart", "Terminate" }
    local picker_opts = {
        prompt_title = "Debug Options",
        finder = finders.new_table({
            results = options,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection[1] == "Debug Tests" then
                    local ok, jdtls_dap = pcall(require, "jdtls.dap")
                    if ok then
                        jdtls_dap.test_class()
                    else
                        vim.notify("jdtls.dap not available", vim.log.levels.WARN)
                    end
                elseif selection[1] == "Debug Main Application" or selection[1] == "Continue" then
                    dap.continue()
                elseif selection[1] == "Restart" then
                    dap.restart()
                elseif selection[1] == "Terminate" then
                    dap.terminate()
                    dapui.close()
                end
            end)
            return true
        end,
    }
    pickers.new(picker_opts, utils.picker_theme):find()
end

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
        { "<leader>bs", open_debug_picker, desc = "Debug session picker" },
    },
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    config = function()
        require("lazydev").setup({
            library = { "nvim-dap-ui" },
        })
        local dap = require("dap")
        local dapui = require("dapui")
        require("dapui").setup({
            layouts = {
                {
                    elements = {
                        { id = "scopes", size = 0.60 },
                        { id = "watches", size = 0.20 },
                        { id = "breakpoints", size = 0.20 },
                    },
                    size = 40,
                    position = "left",
                },
                {
                    elements = {
                        { id = "console", size = 0.60 },
                        { id = "repl", size = 0.40 },
                    },
                    size = 10,
                    position = "bottom",
                },
            },
        })
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.disconnect["dapui_config"] = function()
            dapui.close()
        end
    end,
}