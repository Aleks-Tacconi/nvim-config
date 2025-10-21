local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("nil_ls", {})
cfg:set_formatters({ "nix" }, { "nixfmt" })
cfg:set_indent({ "nix" }, 2)

return cfg:get()
