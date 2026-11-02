---Configure PostgreSQL tooling using the built-in SQLFluff parser.
local cfg = require("utils.lsp").lang_server()
local lint = require("lint")

lint.linters.sqlfluff.args = { "lint", "--format=json", "--dialect", "postgres", "-" }

cfg:add_server("postgres_lsp", {})
cfg:set_formatters({ "sql" }, { "pg_format" })
cfg:set_linters({ "sql" }, { "sqlfluff" })

return cfg:get()
