local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("jsonls", {})
cfg:set_formatters({ "json", "jsonc" }, { "prettier" })
cfg:set_linters({ "json", "jsonc" }, { "jsonlint" })
cfg:set_indent({ "json", "jsonc" }, 2)

return cfg:get()
