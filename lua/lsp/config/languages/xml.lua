local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("lemminx", {})

return cfg:get()
