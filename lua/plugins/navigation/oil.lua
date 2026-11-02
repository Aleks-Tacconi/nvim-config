---Configure Oil navigation and keep Git decorations synchronized with its rows.
return {
    "stevearc/oil.nvim",
    cmd = { "Oil" },
    config = function()
        local utils = require("utils.oil")
        local oil = require("oil")

        local git_status = utils.new_git_status()

        ---Hide ignored entries and untracked dotfiles.
        local function is_hidden_file(name, bufnr)
            local dir = require("oil").get_current_dir(bufnr)
            if not dir or vim.fn.isdirectory(dir) == 0 then
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

        local group = vim.api.nvim_create_augroup("oil-git-diff-stats", { clear = true })
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = { "OilEnter", "OilActionsPost" },
            callback = function(args)
                git_status = utils.new_git_status()
                utils.show_git_diff_stats(args.data.buf or vim.api.nvim_get_current_buf())
            end,
        })
        vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
            group = group,
            callback = function(args)
                if vim.bo[args.buf].filetype == "oil" then
                    git_status = utils.new_git_status()
                    utils.show_git_diff_stats(args.buf)
                end
            end,
        })
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            group = group,
            callback = function(args)
                if vim.bo[args.buf].filetype == "oil" then
                    utils.render_git_diff_stats(args.buf)
                end
            end,
        })
    end,
}
