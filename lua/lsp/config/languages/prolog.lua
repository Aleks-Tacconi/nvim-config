local utils = require("utils.lsp")
local cfg = utils.lang_server()
local lint = require("lint")

cfg:add_server("prolog_ls", {})

cfg:set_formatters({ "prolog" }, { "swipl_fmt" })
cfg:set_linters({ "prolog" }, { "swipl_lint" })

lint.linters.swipl_lint = {
	name = "swipl --lint",
	cmd = "swipl",
	args = { "--lint", "%file" },
	stdin = false,
	parser = require("lint.parser").from_pattern(
		"^(%u%l+): [^:]+:(%d+):?%s*(.+)$",
		{ "severity", "lnum", "message" },
		{
			Error = vim.diagnostic.severity.ERROR,
			Warning = vim.diagnostic.severity.WARN,
			Info = vim.diagnostic.severity.INFO,
		},
		{ source = "swipl" }
	),
}

return cfg:get()

