local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("lemminx", {})
cfg:set_indent({ "xml" }, 2)

return cfg:get()
