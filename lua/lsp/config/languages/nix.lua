local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("nil", {})

cfg:set_formatters({ "nix" }, { "nixfmt" })

return cfg:get()
