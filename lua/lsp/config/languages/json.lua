local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("jsonls", {})
cfg:set_formatters({ "json" }, { "prettier" })
cfg:set_linters({ "json" }, { "jsonlint" })

return cfg:get()
