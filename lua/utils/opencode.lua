local M = {}

local severity_labels = {
	[vim.diagnostic.severity.ERROR] = "ERROR",
	[vim.diagnostic.severity.WARN] = "WARN",
	[vim.diagnostic.severity.INFO] = "INFO",
	[vim.diagnostic.severity.HINT] = "HINT",
}

local function normalize_message(message)
	return (message or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function buffer_name(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return "[No Name]"
	end

	return name
end

local function buffer_filetype(bufnr)
	local filetype = vim.bo[bufnr].filetype
	if filetype == "" then
		return "text"
	end

	return filetype
end

local function send_prompt(lines)
	require("opencode").prompt(table.concat(lines, "\n"), { submit = true })
end

local function send_code_range(bufnr, start_line, end_line)
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local code_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
	if #code_lines == 0 then
		vim.notify("No lines to send", vim.log.levels.INFO, { title = "opencode" })
		return
	end

	local prompt_lines = {
		string.format("Code from %s:%d-%d", buffer_name(bufnr), start_line, end_line),
		"```" .. buffer_filetype(bufnr),
		table.concat(code_lines, "\n"),
		"```",
	}

	send_prompt(prompt_lines)
end

local function tmux(args)
	local result = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
	if result.code ~= 0 then
		return nil, vim.trim(result.stderr or "")
	end

	return vim.trim(result.stdout or "")
end

function M.find_tmux_pane()
	if vim.env.TMUX == nil or vim.env.TMUX == "" then
		return nil
	end

	local output = tmux({ "list-panes", "-F", "#{pane_id}\t#{pane_current_command}\t#{pane_start_command}" })
	if output == nil or output == "" then
		return nil
	end

	for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
		local parts = vim.split(line, "\t", { plain = true })
		local current_command = parts[2] or ""
		local start_command = parts[3] or ""
		if current_command == "opencode" and start_command:match("%-%-port") then
			return parts[1]
		end
	end

	return nil
end

function M.ensure_tmux_pane()
	if vim.env.TMUX == nil or vim.env.TMUX == "" then
		vim.notify("tmux is not running; using the Neovim sidecar instead", vim.log.levels.INFO, { title = "opencode" })
		return nil
	end

	local pane_id = M.find_tmux_pane()
	if pane_id ~= nil then
		vim.notify("Reusing existing tmux opencode pane " .. pane_id, vim.log.levels.INFO, { title = "opencode" })
		return pane_id
	end

	local created_pane, err =
		tmux({ "split-window", "-h", "-d", "-l", "40%", "-P", "-F", "#{pane_id}", "opencode --port" })
	if created_pane == nil then
		vim.notify(
			err ~= "" and err or "Failed to start tmux opencode pane",
			vim.log.levels.ERROR,
			{ title = "opencode" }
		)
		return nil
	end

	vim.notify("Started tmux opencode pane " .. created_pane, vim.log.levels.INFO, { title = "opencode" })
	return created_pane
end

function M.send_current_line()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	send_code_range(bufnr, current_line, current_line)
end

function M.send_visual_lines()
	local bufnr = vim.api.nvim_get_current_buf()
	local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
	local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")
	local start_line = start_pos[1]
	local end_line = end_pos[1]

	if start_line == 0 or end_line == 0 then
		vim.notify("No visual selection found", vim.log.levels.INFO, { title = "opencode" })
		return
	end

	send_code_range(bufnr, start_line, end_line)
end

function M.send_current_line_diagnostics()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	local line_text = vim.api.nvim_buf_get_lines(bufnr, current_line - 1, current_line, false)[1] or ""
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = current_line - 1 })

	if #diagnostics == 0 then
		vim.notify("No diagnostics on current line", vim.log.levels.INFO, { title = "opencode" })
		return
	end

	local diagnostic_lines = {}
	for _, diagnostic in ipairs(diagnostics) do
		local severity = severity_labels[diagnostic.severity] or "UNKNOWN"
		local source = diagnostic.source and (" (" .. diagnostic.source .. ")") or ""
		table.insert(
			diagnostic_lines,
			string.format("- %s%s: %s", severity, source, normalize_message(diagnostic.message))
		)
	end

	local prompt_lines = {
		string.format("Diagnostics for %s:%d", buffer_name(bufnr), current_line),
		"Code:",
		"```" .. buffer_filetype(bufnr),
		line_text,
		"```",
		"Diagnostics:",
	}
	vim.list_extend(prompt_lines, diagnostic_lines)

	send_prompt(prompt_lines)
end

return M
