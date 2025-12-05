local M = {}

-- Define signs
vim.fn.sign_define("JacocoCovered", { text = "✔", texthl = "DiffAdd" })
vim.fn.sign_define("JacocoMissed", { text = "✖", texthl = "DiffDelete" })

M.coverage = {}

-- Find Maven project root by locating pom.xml
function M.find_project_root()
	local path = vim.fn.expand("%:p:h")
	while path ~= "/" do
		if vim.fn.filereadable(path .. "/pom.xml") == 1 then
			return path
		end
		path = vim.fn.fnamemodify(path, ":h")
	end
	return nil
end

-- Parse Jacoco XML and populate coverage table
function M.parse_jacoco()
	local root = M.find_project_root()
	if not root then
		vim.notify("Jacoco: pom.xml not found", vim.log.levels.WARN)
		return
	end

	local xml_path = root .. "/target/site/jacoco/jacoco.xml"
	local f = io.open(xml_path, "r")
	if not f then
		vim.notify("Jacoco: jacoco.xml not found", vim.log.levels.WARN)
		return
	end

	local content = f:read("*a")
	f:close()

	M.coverage = {}
	local count_lines = 0

	-- Parse classes and methods
	for class_block in content:gmatch("<class(.-)</class>") do
		local file = class_block:match('sourcefilename="(.-)"')
		if file then
			M.coverage[file] = M.coverage[file] or {}

			for method_block in class_block:gmatch("<method(.-)</method>") do
				local start_line = tonumber(method_block:match('line="(%d+)"'))
				local missed, covered = method_block:match('<counter type="LINE" missed="(%d+)" covered="(%d+)"')
				if start_line and missed and covered then
					missed, covered = tonumber(missed), tonumber(covered)
					M.coverage[file][start_line] = (covered > 0) and "covered" or "missed"
					count_lines = count_lines + 1
				end
			end
		end
	end

	vim.notify("Jacoco: parsed " .. count_lines .. " method lines")
end

-- Place signs for current buffer
function M.show_signs()
	local buf_name = vim.fn.expand("%:t")
	local buf_cov = nil
	for k, v in pairs(M.coverage) do
		if k:match(buf_name .. "$") then
			buf_cov = v
			break
		end
	end

	if not buf_cov then
		vim.notify("Jacoco: no coverage info for this file")
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	vim.fn.sign_unplace("jacoco", { buffer = bufnr })

	for lnum, status in pairs(buf_cov) do
		local sign = (status == "covered") and "JacocoCovered" or "JacocoMissed"
		vim.fn.sign_place(0, "jacoco", sign, bufnr, { lnum = lnum })
	end
end

-- Refresh coverage asynchronously
function M.refresh()
	local root = M.find_project_root()
	if not root then
		vim.notify("Jacoco: pom.xml not found", vim.log.levels.WARN)
		return
	end

	vim.notify("Jacoco: running Maven in background...")
	vim.fn.jobstart({ "mvn", "clean", "test", "jacoco:report" }, {
		cwd = root,
		on_exit = function(_, code, _)
			vim.schedule(function()
				if code ~= 0 then
					vim.notify("Jacoco: mvn failed with code " .. code, vim.log.levels.ERROR)
				else
					M.parse_jacoco()
					M.show_signs()
					vim.notify("Jacoco: coverage updated")
				end
			end)
		end,
	})
end

return M
