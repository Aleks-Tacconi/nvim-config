---Configure Python tools using the environment of each project.
local utils = require("utils.lsp")
local cfg = utils.lang_server()

-- Find Ruff in the project environment or on PATH.
local function ruff_path(_, ctx)
	return utils.get_path("ruff", ctx and ctx.filename)
end

cfg:add_server("ruff", {
	-- Let Pyright provide documentation instead of Ruff's empty hover responses.
	on_init = function(client)
		client.server_capabilities.hoverProvider = false
	end,
	-- Resolve Ruff when the server starts so project environments are respected.
	cmd = function(dispatchers, config)
		return vim.lsp.rpc.start({ utils.get_path("ruff", config.root_dir), "server" }, dispatchers, {
			cwd = config.cmd_cwd,
			env = config.cmd_env,
			detached = config.detached,
		})
	end,
})

cfg:add_server("pyright", {
	before_init = function(_, config)
		config.settings.python.pythonPath = utils.get_path("python", config.root_dir)
	end,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				diagnosticSeverityOverrides = {
					reportUnusedExpression = "none",
				},
				useLibraryCodeForTypes = true,
			},
		},
	},
})
cfg:set_formatters({ "python" }, { "ruff_organize_imports", "ruff_format" })

local conform = require("conform")
-- Prefer Ruff from the project's environment for formatting and import sorting.
for _, formatter in ipairs({ "ruff_organize_imports", "ruff_format" }) do
	conform.formatters[formatter] = {
		command = ruff_path,
	}
end

return cfg:get()
