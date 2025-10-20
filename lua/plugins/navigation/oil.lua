return {
    "stevearc/oil.nvim",
    config = function()
        local utils = require("utils.oil")
        local oil = require("oil")

        local refresh = require("oil.actions").refresh
        local git_status = utils.new_git_status()
        local orig_refresh = refresh.callback
        refresh.callback = function(...)
            git_status = utils.new_git_status()
            orig_refresh(...)
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
            win_options = {
                signcolumn = "yes",
            },
            view_options = {
                is_hidden_file = is_hidden_file,
            },
        })
    end,
}
