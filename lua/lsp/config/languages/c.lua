local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("clangd", {})
cfg:set_formatters({ "c" }, { "clang-format" })
cfg:set_linters({ "c" }, { "cpplint" })
cfg:set_indent({ "c" }, 2)

return cfg:get()
