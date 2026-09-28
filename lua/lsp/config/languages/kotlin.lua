local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("kotlin_language_server", {
	cmd = { utils.get_path("kotlin-language-server") },
})

cfg:set_formatters({ "kotlin" }, { "ktlint" })
cfg:set_linters({ "kotlin" }, { "ktlint" })

local lint = require("lint")
lint.linters.ktlint.cmd = utils.get_path("ktlint")

return cfg:get()
