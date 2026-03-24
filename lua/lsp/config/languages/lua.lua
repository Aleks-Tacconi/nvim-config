local utils = require("utils.lsp")
local cfg = utils.lang_server()

	cfg:add_server("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = { enable = false },
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
cfg:set_formatters({ "lua" }, { "stylua" })
cfg:set_linters({ "lua" }, { "luacheck" })

return cfg:get()
