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
		linters_ft = {},
	}

	function obj:add_server(name, config)
		self.servers[name] = config
	end

	function obj:set_linters(ft, linters_list)
		local lint = require("lint")
		for _, filetype in ipairs(ft) do
			lint.linters_by_ft[filetype] = linters_list
			vim.list_extend(self.linters_ft, { filetype })
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

	function obj:set_indent(ft, indent)
		for _, filetype in ipairs(ft) do
			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetype,
				callback = function()
					vim.opt_local.tabstop = indent
					vim.opt_local.shiftwidth = indent
				end,
			})
		end
	end

	function obj:get()
		return {
			servers = self.servers,
			linters_ft = self.linters_ft,
		}
	end

	return obj
end

return M
