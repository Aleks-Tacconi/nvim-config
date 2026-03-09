local M = {}

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

function M.focus_tmux_pane()
	local pane_id = M.ensure_tmux_pane()
	if pane_id == nil then
		return
	end

	local _, err = tmux({ "select-pane", "-t", pane_id })
	if err ~= nil and err ~= "" then
		vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
	end
end

return M
