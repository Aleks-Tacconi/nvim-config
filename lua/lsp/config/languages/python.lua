local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("pyright", {
	settings = {
		python = {
			pythonPath = utils.get_path("python"),
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
			},
		},
	},
})
cfg:set_formatters({ "python" }, { "isort", "black" })
cfg:set_linters({ "python" }, { "pylint" })

local lint = require("lint")
lint.linters.pylint.cmd = utils.get_path("pylint")

return cfg:get()
