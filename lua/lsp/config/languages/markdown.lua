local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("marksman", {})

-- cfg:set_linters({ "markdown" }, { "markdownlint" })
cfg:set_formatters({ "markdown", "quarto" }, { "prettier_markdown", "injected" })
cfg:set_indent({ "markdown" }, 2)

return cfg:get()
