---Language server, formatter, and linter configuration for Rust.

local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				buildScripts = {
					enable = true,
				},
			},
			check = {
				command = "clippy",
			},
			procMacro = {
				enable = true,
			},
		},
	},
})
cfg:set_formatters({ "rust" }, { "rustfmt" })

return cfg:get()
