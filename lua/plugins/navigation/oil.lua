return {
    "stevearc/oil.nvim",
    cmd = { "Oil" },
    config = function()
        local utils = require("utils.oil")
        local oil = require("oil")

        local refresh = require("oil.actions").refresh
        local git_status = utils.new_git_status()
        local orig_refresh = refresh.callback
        refresh.callback = function(...)
            local bufnr = vim.api.nvim_get_current_buf()
            git_status = utils.new_git_status()
            orig_refresh(...)
            vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                    utils.show_git_diff_stats(bufnr)
                end
            end, 200)
        end

        local Path = require("plenary.path")
        local function is_hidden_file(name, bufnr)
            local dir = require("oil").get_current_dir(bufnr)
            if not Path:new(dir):exists() then
                return false
            end

            local is_dotfile = vim.startswith(name, ".") and name ~= ".."
            if is_dotfile then
                return not git_status[dir].tracked[name]
            else
                return git_status[dir].ignored[name]
            end
        end

        oil.setup({
            keymaps = {
                ["<CR>"] = utils.open_with_default_app,
                ["<2-LeftMouse>"] = utils.open_with_default_app,
            },
            view_options = {
                is_hidden_file = is_hidden_file,
            },
        })

        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("oil-git-diff-stats", { clear = true }),
            pattern = "OilEnter",
            callback = function(args)
                utils.show_git_diff_stats(args.data.buf)
            end,
        })
    end,
}
