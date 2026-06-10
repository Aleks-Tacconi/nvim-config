local M = {}

local external_extensions = {
    avif = true,
    bmp = true,
    doc = true,
    docx = true,
    gif = true,
    jpeg = true,
    ipynb = true,
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
