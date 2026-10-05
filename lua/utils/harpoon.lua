---Manage per-directory file marks and an editable floating quick menu.
local M = {}

local LIST_KEY = "__harpoon_files"
local data_dir = vim.fn.stdpath("data") .. "/harpoon"
local lists, menu = {}, {}
local hooks_registered = false

---Normalize `path` relative to `cwd` when inside `cwd`, or as an absolute path.
local function normalize_path(path, cwd)
	if path == "" then
		return ""
	end
	local norm_cwd = vim.fs.normalize(cwd)
	local abs = vim.fs.normalize(vim.startswith(path, "/") and path or (norm_cwd .. "/" .. path))
	return vim.fs.relpath(norm_cwd, abs) or abs
end

---Return the JSON storage path for `cwd`, matching Harpoon2's file layout.
local function storage_path(cwd)
	return data_dir .. "/" .. vim.fn.sha256(cwd) .. ".json"
end

---Read and JSON-decode `path`, returning an empty table when missing or invalid.
local function read_json(path)
	if vim.fn.filereadable(path) == 0 then
		return {}
	end
	local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
	return (ok and type(data) == "table") and data or {}
end

---Decode one saved entry (JSON string or table) into `{ value, context }`.
local function decode_entry(entry)
	if type(entry) == "string" then
		local ok, decoded = pcall(vim.json.decode, entry)
		entry = ok and decoded or nil
	end
	if type(entry) ~= "table" or type(entry.value) ~= "string" or entry.value == "" then
		return nil
	end
	local ctx = type(entry.context) == "table" and entry.context or {}
	return { value = entry.value, context = { row = tonumber(ctx.row) or 1, col = tonumber(ctx.col) or 0 } }
end

---Read the persisted mark list for `cwd` from disk.
local function read_list(cwd)
	local data = read_json(storage_path(cwd))
	local raw_items = type(data[cwd]) == "table" and data[cwd][LIST_KEY] or nil
	if type(raw_items) ~= "table" then
		return { items = {}, len = 0 }
	end
	local items, len = {}, 0
	for k, v in pairs(raw_items) do
		local idx, decoded = tonumber(k), decode_entry(v)
		if idx and idx > 0 and decoded then
			items[idx], len = decoded, math.max(len, idx)
		end
	end
	return { items = items, len = len }
end

---Write `list` for `cwd` to disk in Harpoon2-compatible JSON format.
local function save_list(cwd, list)
	vim.fn.mkdir(data_dir, "p")
	local path = storage_path(cwd)
	local data, encoded = read_json(path), {}
	for i = 1, list.len do
		encoded[i] = list.items[i] and vim.json.encode(list.items[i]) or vim.NIL
	end
	data[cwd] = data[cwd] or {}
	data[cwd][LIST_KEY] = encoded
	vim.fn.writefile({ vim.json.encode(data) }, path)
end

---Register `BufLeave` and `VimLeavePre` hooks once to remember cursor positions.
local function ensure_hooks()
	if hooks_registered then
		return
	end
	hooks_registered = true
	local group = vim.api.nvim_create_augroup("native-harpoon", { clear = true })
	vim.api.nvim_create_autocmd("BufLeave", {
		group = group,
		callback = function(ev)
			local cwd = vim.uv.cwd()
			local list = cwd and lists[cwd]
			if not list or vim.bo[ev.buf].buftype ~= "" then
				return
			end
			local rel = normalize_path(vim.api.nvim_buf_get_name(ev.buf), cwd)
			for i = 1, list.len do
				if list.items[i] and list.items[i].value == rel then
					local pos = vim.api.nvim_win_get_cursor(0)
					list.items[i].context = { row = pos[1], col = pos[2] }
					break
				end
			end
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			local cwd = vim.uv.cwd()
			if cwd and lists[cwd] then
				save_list(cwd, lists[cwd])
			end
		end,
	})
end

---Return the in-memory mark list for `cwd`, loading it from disk on first access.
local function get_list(cwd)
	ensure_hooks()
	lists[cwd] = lists[cwd] or read_list(cwd)
	return lists[cwd]
end

---Apply edited quick-menu lines to `list` while preserving cursor contexts.
local function apply_menu_lines(cwd, list, lines)
	local len = #lines
	while len > 0 and vim.trim(lines[len]) == "" do
		len = len - 1
	end
	local by_value, new_items, seen = {}, {}, {}
	for i = 1, list.len do
		if list.items[i] then
			by_value[list.items[i].value] = list.items[i]
		end
	end
	for i = 1, len do
		local rel = normalize_path(vim.trim(lines[i]), cwd)
		if rel ~= "" and not seen[rel] then
			seen[rel] = true
			new_items[i] = by_value[rel] or { value = rel, context = { row = 1, col = 0 } }
		end
	end
	list.items, list.len = new_items, len
	save_list(cwd, list)
end

---Close the floating quick menu, optionally saving buffer edits first.
local function close_menu(save)
	local win, buf, cwd, list = menu.win, menu.buf, menu.cwd, menu.list
	if not win and not buf then
		return
	end
	menu = {}
	if save and cwd and list and buf and vim.api.nvim_buf_is_valid(buf) then
		apply_menu_lines(cwd, list, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
	end
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = true })
	end
end

---Open the file at `index` in `list` and restore its saved cursor position on first load.
local function select_from_list(cwd, list, index)
	local item = list.items[index]
	if not item or item.value == "" then
		return
	end
	local bufnr = vim.fn.bufadd(normalize_path(item.value, cwd))
	local first_load = not vim.api.nvim_buf_is_loaded(bufnr)
	if first_load then
		vim.fn.bufload(bufnr)
		vim.bo[bufnr].buflisted = true
	end
	vim.api.nvim_set_current_buf(bufnr)
	if first_load and item.context then
		local row = math.min(math.max(item.context.row or 1, 1), vim.api.nvim_buf_line_count(bufnr))
		local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
		vim.api.nvim_win_set_cursor(0, { row, math.min(math.max(item.context.col or 0, 0), #line) })
	end
end

---Attach close, jump, and save handlers to the floating quick-menu buffer.
local function bind_menu(buf, cwd, list)
	for _, key in ipairs({ "q", "<Esc>" }) do
		vim.keymap.set("n", key, function()
			close_menu(true)
		end, { buffer = buf, silent = true, nowait = true })
	end
	vim.keymap.set("n", "<CR>", function()
		local idx = vim.api.nvim_win_get_cursor(0)[1]
		close_menu(true)
		select_from_list(cwd, list, idx)
	end, { buffer = buf, silent = true })
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			vim.bo[buf].modified = false
			vim.schedule(function()
				close_menu(true)
			end)
		end,
	})
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			close_menu(true)
		end,
	})
end

---Add the current file buffer to the first available slot for the working directory.
function M.add()
	local cwd, name = vim.uv.cwd(), vim.api.nvim_buf_get_name(0)
	if vim.bo.buftype ~= "" or not cwd or name == "" then
		return
	end
	local rel, list = normalize_path(name, cwd), get_list(cwd)
	for i = 1, list.len do
		if list.items[i] and list.items[i].value == rel then
			return
		end
	end
	local slot = 1
	while list.items[slot] do
		slot = slot + 1
	end
	local pos = vim.api.nvim_win_get_cursor(0)
	list.items[slot] = { value = rel, context = { row = pos[1], col = pos[2] } }
	list.len = math.max(list.len, slot)
	save_list(cwd, list)
end

---Jump to mark `index` in the current working directory.
function M.select(index)
	if menu.win then
		close_menu(true)
	end
	local cwd = vim.uv.cwd()
	if cwd then
		select_from_list(cwd, get_list(cwd), index)
	end
end

---Toggle the editable floating Harpoon quick menu.
function M.toggle_menu()
	if menu.win and vim.api.nvim_win_is_valid(menu.win) then
		close_menu(true)
		return
	end
	local cwd = vim.uv.cwd()
	if not cwd then
		return
	end
	local current_rel, list = normalize_path(vim.api.nvim_buf_get_name(0), cwd), get_list(cwd)
	local lines, cursor_row = {}, 1
	for i = 1, list.len do
		lines[i] = list.items[i] and list.items[i].value or ""
		if lines[i] ~= "" and lines[i] == current_rel then
			cursor_row = i
		end
	end
	local width, height = math.max(math.floor(vim.o.columns * 0.62569), 40), 8
	local buf = vim.api.nvim_create_buf(false, true)
	pcall(vim.api.nvim_buf_set_name, buf, "harpoon://menu")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype, vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].modified = "harpoon", "acwrite", "wipe", false
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor", title = "Harpoon", title_pos = "left", style = "minimal", border = "single",
		row = math.floor(((vim.o.lines - height) / 2) - 1), col = math.floor((vim.o.columns - width) / 2),
		width = width, height = height,
	})
	vim.wo[win].number = true
	if #lines > 0 then
		vim.api.nvim_win_set_cursor(win, { cursor_row, 0 })
	end
	menu = { win = win, buf = buf, cwd = cwd, list = list }
	bind_menu(buf, cwd, list)
end

return M
