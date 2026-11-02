---Configure Java tooling with a separate language-server workspace per project.
local utils = require("utils.lsp")
local cfg = utils.lang_server()
local java_home = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.exepath("java")), ":h:h")

vim.keymap.set("n", "<leader>jc", function()
	require("utils.java-code-coverage").refresh()
end, { desc = "Refresh Java coverage" })

cfg:add_server("jdtls", {
	workspace_required = true,
	cmd = function(dispatchers, config)
		local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.sha256(config.root_dir)
		return vim.lsp.rpc.start({ "jdtls", "-data", workspace }, dispatchers, {
			cwd = config.cmd_cwd,
			env = config.cmd_env,
			detached = config.detached,
		})
	end,
	settings = {
		java = {
			configuration = {
				runtimes = {
					{ name = "JavaSE-25", path = java_home },
				},
				updateBuildConfiguration = "interactive",
			},
			eclipse = { downloadSources = true },
			maven = { downloadSources = true },
			format = { enabled = true },
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
				importOrder = { "java", "javax", "com", "org" },
			},
			sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				useBlocks = true,
			},
			implementationsCodeLens = { enabled = true },
			referencesCodeLens = { enabled = true },
			references = { includeDecompiledSources = true },
			signatureHelp = { enabled = true },
		},
	},
	init_options = { extendedClientCapabilities = require("jdtls").extendedClientCapabilities },
})

cfg:set_linters({ "java" }, { "checkstyle" })
cfg:set_formatters({ "java" }, { "google-java-format" })
cfg:set_indent({ "java" }, 2)

return cfg:get()
