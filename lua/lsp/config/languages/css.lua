local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("cssls", {})
cfg:set_formatters({ "css" }, { "prettier" })
cfg:set_linters({ "css" }, { "stylelint" })

return cfg:get()

--
-- npm install -D stylelint stylelint-config-standard
--
-- ProjectRoot/.stylelintrc.json
-- {
-- "extends": ["stylelint-config-standard"]
-- }
