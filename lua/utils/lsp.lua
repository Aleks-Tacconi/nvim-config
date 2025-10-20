local M = {}

function M.get_path(executable)
	local base_paths = {
		vim.fn.trim(vim.fn.system("poetry env info -p")) .. "/bin/",
		vim.fn.getcwd() .. "/venv/bin/",
		vim.fn.getcwd() .. "/.venv/bin/",
	}

	for _, base in ipairs(base_paths) do
		local full_path = base .. executable
		if vim.fn.filereadable(full_path) == 1 then
			return full_path
		end
	end

	return vim.fn.trim(vim.fn.system("which " .. executable))
end

function M.lang_server()
	local obj = {
		servers = {},
		formatters = {},
		linters = {},
	}

	function obj:add_server(name, config)
		self.servers[name] = config
	end

	function obj:set_linters(ft, linters_list)
		local lint = require("lint")
		for _, filetype in ipairs(ft) do
			lint.linters_by_ft[filetype] = linters_list
		end

		vim.list_extend(self.linters, linters_list)
	end

	function obj:set_formatters(ft, formatters_list)
		local conform = require("conform")
		for _, filetype in ipairs(ft) do
			conform.formatters_by_ft[filetype] = formatters_list
		end

		vim.list_extend(self.formatters, formatters_list)
	end

	function obj:get()
		local tools = {}
		vim.list_extend(tools, self.formatters)
		vim.list_extend(tools, self.linters)

		return {
			servers = self.servers,
		}
	end

	return obj
end

return M
