local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("gopls", {})
cfg:set_formatters({ "go" }, { "gofmt" })
cfg:set_linters({ "go" }, { "golangcilint" })

return cfg:get()
