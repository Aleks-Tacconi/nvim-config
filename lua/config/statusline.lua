---Configure the minimal global statusline matching the Rose Pine Moon palette.
local M = {}

local head_cache = {}

local MODE_NAMES = {
	["n"] = "NORMAL",
	["no"] = "O-PENDING",
	["nov"] = "O-PENDING",
	["noV"] = "O-PENDING",
	["no\22"] = "O-PENDING",
	["niI"] = "NORMAL",
	["niR"] = "NORMAL",
	["niV"] = "NORMAL",
	["nt"] = "NORMAL",
	["ntT"] = "NORMAL",
	["v"] = "VISUAL",
	["vs"] = "VISUAL",
	["V"] = "V-LINE",
	["Vs"] = "V-LINE",
	["\22"] = "V-BLOCK",
	["\22s"] = "V-BLOCK",
	["s"] = "SELECT",
	["S"] = "S-LINE",
	["\19"] = "S-BLOCK",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["ix"] = "INSERT",
	["R"] = "REPLACE",
	["Rc"] = "REPLACE",
	["Rx"] = "REPLACE",
	["Rv"] = "V-REPLACE",
	["Rvc"] = "V-REPLACE",
	["Rvx"] = "V-REPLACE",
	["c"] = "COMMAND",
	["cv"] = "EX",
	["ce"] = "EX",
	["r"] = "REPLACE",
	["rm"] = "MORE",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}

---Escape `%` characters so dynamic text is safe inside `statusline`.
local function escape(text)
	return (text:gsub("%%", "%%%%"))
end

---Define transparent statusline highlight groups for Rose Pine Moon.
local function set_highlights()
	vim.api.nvim_set_hl(0, "StatusLine", { fg = "#e0def4", bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#6e6a86", bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineTerm", { fg = "#e0def4", bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineTermNC", { fg = "#6e6a86", bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineMode", { fg = "#c4a7e7", bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineMuted", { fg = "#6e6a86", bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLineFile", { fg = "#e0def4", bg = "NONE" })
end

---Read the branch or short commit hash from `.git/HEAD` for `root`.
local function read_git_head(root)
	local git_path = root .. "/.git"
	local stat = vim.uv.fs_stat(git_path)
	if not stat then
		return ""
	end
	local git_dir = git_path
	if stat.type == "file" then
		local f = io.open(git_path, "r")
		local line = f and f:read("*l")
		if f then
			f:close()
		end
		local rel = line and line:match("^gitdir:%s*(.+)$")
		if not rel then
			return ""
		end
		git_dir = vim.startswith(rel, "/") and rel or (root .. "/" .. rel)
	end
	local f = io.open(git_dir .. "/HEAD", "r")
	if not f then
		return ""
	end
	local head = f:read("*l") or ""
	f:close()
	return head:match("^ref: refs/heads/(.+)$") or head:sub(1, 6)
end

---Resolve the current Git branch from Gitsigns or cached `.git/HEAD`.
local function branch_section()
	local branch = vim.b.gitsigns_head
	if not branch then
		local name = vim.api.nvim_buf_get_name(0):gsub("^oil:///", "/")
		local dir = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
		if head_cache[dir] == nil then
			local root = vim.fs.root(dir, ".git")
			head_cache[dir] = root and read_git_head(root) or ""
		end
		branch = head_cache[dir]
	end
	if not branch or branch == "" then
		return ""
	end
	return "%#StatusLineMuted#  " .. escape(branch) .. " "
end

---Format added, modified, and removed hunk counts from Gitsigns.
local function diff_section()
	local diff = vim.b.gitsigns_status_dict
	if not diff then
		return ""
	end
	local parts = {}
	if (diff.added or 0) > 0 then
		parts[#parts + 1] = "%#GitSignsAdd#+" .. diff.added
	end
	if (diff.changed or 0) > 0 then
		parts[#parts + 1] = "%#GitSignsChange#~" .. diff.changed
	end
	if (diff.removed or 0) > 0 then
		parts[#parts + 1] = "%#GitSignsDelete#-" .. diff.removed
	end
	return #parts > 0 and (" " .. table.concat(parts, " ") .. " ") or ""
end

---Shorten directory segments to their first character when `path` exceeds `max_len`.
local function shorten_path(path, max_len)
	if #path <= max_len then
		return path
	end
	local parts = vim.split(path, "/", { plain = true })
	local len = #path
	for i = 1, #parts - 1 do
		if len <= max_len then
			break
		end
		local seg = parts[i]
		local short = seg:sub(1, vim.startswith(seg, ".") and 2 or 1)
		parts[i] = short
		len = len - (#seg - #short)
	end
	return table.concat(parts, "/")
end

---Format the relative filename and buffer state flags.
local function file_section()
	local name = vim.fn.expand("%:~:.")
	name = name ~= "" and shorten_path(name, vim.o.columns - 40) or "[No Name]"
	local flags = {}
	if vim.bo.modified then
		flags[#flags + 1] = "[+]"
	end
	if not vim.bo.modifiable or vim.bo.readonly then
		flags[#flags + 1] = "[-]"
	end
	local suffix = #flags > 0 and (" " .. table.concat(flags, "")) or ""
	return "%#StatusLineFile# " .. escape(name) .. suffix .. " "
end

---Format the notebook kernel status when viewing an `.ipynb` buffer.
local function notebook_section()
	if not vim.api.nvim_buf_get_name(0):match("%.ipynb$") then
		return ""
	end
	local status = require("utils.notebook").status()
	return status ~= "" and ("%#StatusLineMuted# " .. escape(status) .. " ") or ""
end

---Format the colored devicon and filetype label.
local function filetype_section()
	local ft = vim.bo.filetype
	if ft == "" then
		return ""
	end
	local ok, devicons = pcall(require, "nvim-web-devicons")
	local icon, icon_hl
	if ok then
		icon, icon_hl = devicons.get_icon(vim.fn.expand("%:t"))
		if not icon then
			icon, icon_hl = devicons.get_icon_by_filetype(ft)
		end
	end
	icon = icon or ""
	icon_hl = icon_hl or "DevIconDefault"
	return " %#" .. icon_hl .. "#" .. icon .. " %#StatusLineMuted#" .. escape(ft) .. " "
end

---Format the buffer encoding and `line:column` cursor position.
local function position_section()
	local enc = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
	local pos = vim.api.nvim_win_get_cursor(0)
	return "%#StatusLineMuted# " .. escape(enc) .. " " .. pos[1] .. ":" .. (pos[2] + 1) .. " "
end

---Render the complete statusline expression for the active window.
function M.render()
	if vim.bo.filetype == "lazy" then
		return ""
	end
	local mode_code = vim.api.nvim_get_mode().mode
	local mode = "%#StatusLineMode# " .. escape(MODE_NAMES[mode_code] or mode_code) .. " "
	return table.concat({
		mode,
		branch_section(),
		diff_section(),
		file_section(),
		"%#StatusLine#%=",
		notebook_section(),
		filetype_section(),
		position_section(),
	})
end

---Initialize statusline highlights, autocommands, and `vim.o.statusline`.
function M.setup()
	set_highlights()
	local group = vim.api.nvim_create_augroup("native-statusline", { clear = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = set_highlights,
	})
	vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FocusGained" }, {
		group = group,
		callback = function()
			head_cache = {}
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "GitSignsUpdate",
		callback = function()
			vim.cmd.redrawstatus()
		end,
	})
	vim.o.statusline = "%!v:lua.require'config.statusline'.render()"
end

return M
