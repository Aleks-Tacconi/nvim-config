---Configure language tools and resolve executables relative to their project.
local M = {}

-- Cache Poetry environments per project to avoid repeated shell calls.
local _poetry_cache = {}

---Find a Poetry environment once per project, when Poetry is available.
local function poetry_bin_dir(root)
	if _poetry_cache[root] == nil then
		_poetry_cache[root] = ""
		if vim.fn.executable("poetry") == 1 and vim.fn.filereadable(root .. "/pyproject.toml") == 1 then
			local result = vim.system({ "poetry", "env", "info", "-p" }, { cwd = root, text = true }):wait()
			local path = vim.trim(result.stdout)
			if result.code == 0 and path ~= "" then
				_poetry_cache[root] = path .. "/bin/"
			end
		end
	end
	return _poetry_cache[root]
end

---Resolve a project executable, falling back to PATH or its command name.
function M.get_path(executable, path)
	path = path or vim.api.nvim_buf_get_name(0)
	local start = path ~= "" and path or vim.fn.getcwd()
	local root = vim.fs.root(start, { { "pyproject.toml", ".git", ".venv", "venv", "requirements.txt", "setup.py" } })
	root = root or (vim.fn.isdirectory(start) == 1 and start or vim.fs.dirname(start))
	local base_paths = {
		poetry_bin_dir(root),
		root .. "/venv/bin/",
		root .. "/.venv/bin/",
	}

	for _, base in ipairs(base_paths) do
		if base ~= "" then
			local full_path = base .. executable
			if vim.fn.executable(full_path) == 1 then
				return full_path
			end
		end
	end

	local resolved = vim.fn.exepath(executable)
	return resolved ~= "" and resolved or executable
end

---Build the server, formatter, linter, and indentation settings for a language.
function M.lang_server()
	local obj = {
		servers = {},
		formatters = {},
		linters = {},
		linters_ft = {},
	}

	---Register a language server and its overrides.
	function obj:add_server(name, config)
		self.servers[name] = config
	end

	---Assign linters to the given filetypes.
	function obj:set_linters(ft, linters_list)
		local lint = require("lint")
		for _, filetype in ipairs(ft) do
			lint.linters_by_ft[filetype] = linters_list
			vim.list_extend(self.linters_ft, { filetype })
		end

		vim.list_extend(self.linters, linters_list)
	end

	---Assign formatters to the given filetypes.
	function obj:set_formatters(ft, formatters_list)
		local conform = require("conform")
		for _, filetype in ipairs(ft) do
			conform.formatters_by_ft[filetype] = formatters_list
		end

		vim.list_extend(self.formatters, formatters_list)
	end

	---Apply language indentation to current and future buffers.
	function obj.set_indent(_, ft, indent)
		---Set the indentation width in one buffer.
		local function apply(buf)
			vim.bo[buf].tabstop = indent
			vim.bo[buf].shiftwidth = indent
			vim.bo[buf].softtabstop = indent
		end

		for _, filetype in ipairs(ft) do
			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetype,
				callback = function(ev)
					apply(ev.buf)
				end,
			})
		end

		if vim.tbl_contains(ft, vim.bo.filetype) then
			apply(0)
		end
	end

	---Return the settings consumed by the language loader.
	function obj:get()
		return {
			servers = self.servers,
			linters_ft = self.linters_ft,
		}
	end

	return obj
end

return M
