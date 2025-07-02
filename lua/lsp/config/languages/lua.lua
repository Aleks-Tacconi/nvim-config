local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("lua_ls", {
	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
})
cfg:set_formatters({ "lua" }, { "stylua" })
cfg:set_linters({ "lua" }, { "luacheck" })

return cfg:get()
