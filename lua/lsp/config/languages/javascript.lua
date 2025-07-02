local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("ts_ls", {})
cfg:set_formatters({ "javascript" }, { "prettier" })
cfg:set_linters({ "javascript" } , { "eslint_d" })

-- NOTE: to generate eslint_d config file:
-- npm init -y
-- npx eslint --init

return cfg:get()
