local cfg = require("utils.lsp").lang_server()
local lint = require("lint")

lint.linters.sqlfluff = {
	name = "sqlfluff",
	cmd = "sqlfluff",
	args = { "lint", "--dialect", "postgres", "--ignore-parse-errors", "%file" },
	stdin = false,
	stream = "stdout",
	parser = require("lint.parser").from_pattern("(%d+):(%d+): %w+ (.+)", { "lnum", "col", "message" }),
}

cfg:add_server("postgres_lsp", {})
cfg:set_formatters({ "sql" }, { "pg_format" })
cfg:set_linters({ "sql" }, { "sqlfluff" })

return cfg:get()
