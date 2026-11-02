---Open Oil entries and decorate them with current Git changes.
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

---Return the extension used to choose an external application.
local function extension_for(name)
    return name:match("%.([^%.]+)$") or ""
end

---Open files with their usual editor or external application.
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

---Read NUL-delimited Git paths and collapse children to their visible directory.
local function parse_output(proc)
    local result = proc:wait()
    local ret = {}
    if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\0", { plain = true, trimempty = true }) do
            line = line:match("^[^/]+")
            ret[line] = true
        end
    end
    return ret
end

---Return the aggregate for a file or its visible parent directory.
local function entry_stats(stats, path)
    local entry = path:match("^[^/]+")
    stats[entry] = stats[entry] or { added = 0, removed = 0 }
    return stats[entry]
end

---Aggregate numeric and binary changes without Git's filename quoting.
local function parse_diff_stats(output)
    local stats = {}
    for record in vim.gsplit(output, "\0", { plain = true, trimempty = true }) do
        local added, removed, path = record:match("^([^\t]+)\t([^\t]+)\t(.+)$")
        if path then
            local stat = entry_stats(stats, path)
            stat.added = stat.added + (tonumber(added) or 0)
            stat.removed = stat.removed + (tonumber(removed) or 0)
        end
    end
    return stats
end

---Redraw cached markers against the current filenames after Oil buffer edits.
function M.render_git_diff_stats(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, git_stats_namespace, 0, -1)
    local stats = vim.b[bufnr].oil_git_stats or {}
    local oil = require("oil")
    for lnum in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local entry = oil.get_entry_on_line(bufnr, lnum)
        local stat = entry and stats[entry.parsed_name or entry.name]
        if stat then
            local text = {}
            if stat.added > 0 or stat.removed > 0 then
                text = { { "  +" .. stat.added, "Added" }, { " -" .. stat.removed, "Removed" } }
            elseif not stat.untracked then
                text = { { "  ~", "Changed" } }
            end
            if stat.untracked then
                table.insert(text, { "  ??", "Added" })
            end
            vim.api.nvim_buf_set_extmark(bufnr, git_stats_namespace, lnum - 1, 0, {
                virt_text = text,
                virt_text_pos = "eol",
                invalidate = true,
                undo_restore = false,
            })
        end
    end
end

---Refresh Git counts and untracked markers, discarding obsolete async responses.
function M.show_git_diff_stats(bufnr)
    local oil = require("oil")
    local dir = oil.get_current_dir(bufnr)
    if not dir then
        return
    end
    local request = (vim.b[bufnr].oil_git_request or 0) + 1
    vim.b[bufnr].oil_git_request = request
    local results = {}
    ---Apply both Git results only to the buffer and request that started them.
    local function finish(kind, result)
        results[kind] = result
        if not results.diff or not results.untracked then
            return
        end
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) or oil.get_current_dir(bufnr) ~= dir
                or vim.b[bufnr].oil_git_request ~= request then
                return
            end
            local stats = parse_diff_stats(results.diff.stdout or "")
            if results.untracked.code == 0 then
                for path in vim.gsplit(results.untracked.stdout, "\0", { plain = true, trimempty = true }) do
                    entry_stats(stats, path).untracked = true
                end
            end
            vim.b[bufnr].oil_git_stats = stats
            M.render_git_diff_stats(bufnr)
        end)
    end
    local args = { "git", "diff", "--numstat", "-z", "--no-renames", "HEAD", "--relative", "--", "." }
    vim.system(args, { cwd = dir, text = true }, function(result)
        if result.code == 128 then
            args[6] = "--cached" -- A new repository has no HEAD yet.
            vim.system(args, { cwd = dir, text = true }, function(cached) finish("diff", cached) end)
        else
            finish("diff", result)
        end
    end)
    vim.system({ "git", "ls-files", "--others", "--exclude-standard", "-z", "--", "." },
        { cwd = dir, text = true }, function(result) finish("untracked", result) end)
end

---Cache tracked and ignored paths for Oil's hidden-file filter.
function M.new_git_status()
    return setmetatable({}, {
        __index = function(self, key)
            local ignore_proc = vim.system(
                { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory", "-z" },
                {
                    cwd = key,
                    text = true,
                }
            )
            local tracked_proc = vim.system({ "git", "ls-files", "--cached", "-z" }, {
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
