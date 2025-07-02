local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("html", {
	filetypes = { "html", "htmldjango" },
})
cfg:set_formatters({ "html", "htmldjango" }, { "prettier" })
cfg:set_linters({ "html", "htmldjango" }, { "htmlhint" })

return cfg:get()
