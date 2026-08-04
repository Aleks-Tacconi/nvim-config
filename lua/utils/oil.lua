local M = {}
local git_stats_namespace = vim.api.nvim_create_namespace("oil-git-diff-stats")

local external_extensions = {
    avif = true,
    bmp = true,
    doc = true,
    docx = true,
    gif = true,
    jpeg = true,
    jpg = true,
    mkv = true,
    mov = true,
    mp3 = true,
    mp4 = true,
    odp = true,
    ods = true,
    odt = true,
    pdf = true,
    png = true,
    ppt = true,
    pptx = true,
    svg = true,
    tiff = true,
    wav = true,
    webp = true,
    xls = true,
    xlsx = true,
    zip = true,
}

local function extension_for(name)
    return name:match("%.([^%.]+)$") or ""
end

function M.open_with_default_app()
    local oil = require("oil")
    local actions = require("oil.actions")
    local entry = oil.get_cursor_entry()

    if not entry then
        return
    end

    if entry.type == "directory" then
        actions.select.callback()
        return
    end

    local extension = extension_for(entry.name):lower()
    if external_extensions[extension] then
        actions.open_external.callback()
        return
    end

    actions.select.callback()
end

local function parse_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
            line = line:gsub("/$", "")
            ret[line] = true
        end
    end
    return ret
end

---Aggregates Git numstat output by the visible entry in the current directory.
local function parse_diff_stats(output)
    local stats = {}
    for line in vim.gsplit(output, "\n", { plain = true, trimempty = true }) do
        local added, removed, path = line:match("^(%d+)\t(%d+)\t(.+)$")
        local entry = path and path:match("^[^/]+")
        if entry then
            stats[entry] = stats[entry] or { added = 0, removed = 0 }
            stats[entry].added = stats[entry].added + tonumber(added)
            stats[entry].removed = stats[entry].removed + tonumber(removed)
        end
    end
    return stats
end

---Displays added and removed line totals beside entries in an Oil buffer.
function M.show_git_diff_stats(bufnr)
    local oil = require("oil")
    local dir = oil.get_current_dir(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, git_stats_namespace, 0, -1)
    if not dir then
        return
    end

    vim.system({ "git", "diff", "--numstat", "HEAD", "--relative", "--", "." }, { cwd = dir, text = true }, function(result)
        vim.schedule(function()
            if result.code ~= 0 or not vim.api.nvim_buf_is_valid(bufnr) or oil.get_current_dir(bufnr) ~= dir then
                return
            end

            local stats = parse_diff_stats(result.stdout)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local max_width = 0
            for _, line in ipairs(lines) do
                max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
            end

            vim.api.nvim_buf_clear_namespace(bufnr, git_stats_namespace, 0, -1)
            for lnum, line in ipairs(lines) do
                local entry = oil.get_entry_on_line(bufnr, lnum)
                local stat = entry and stats[entry.name]
                if stat then
                    local padding = string.rep(" ", max_width - vim.fn.strdisplaywidth(line) + 2)
                    vim.api.nvim_buf_set_extmark(bufnr, git_stats_namespace, lnum - 1, #line, {
                        virt_text = {
                            { padding, "Normal" },
                            { "+" .. stat.added, "Added" },
                            { " ", "Normal" },
                            { "-" .. stat.removed, "Removed" },
                        },
                        virt_text_pos = "inline",
                    })
                end
            end
        end)
    end)
end

function M.new_git_status()
    return setmetatable({}, {
        __index = function(self, key)
            local ignore_proc = vim.system(
                { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
                {
                    cwd = key,
                    text = true,
                }
            )
            local tracked_proc = vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, {
                cwd = key,
                text = true,
            })
            local ret = {
                ignored = parse_output(ignore_proc),
                tracked = parse_output(tracked_proc),
            }

            rawset(self, key, ret)
            return ret
        end,
    })
end

return M
