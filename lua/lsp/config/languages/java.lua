-- readlink -f $(which java)
-- nix eval --raw nixpkgs#jdt-language-server
-- ..                    #vscode-extensions.vscjava.vscode-java-debug
-- ..                    #vscode-extensions.vscjava.vscode-java-test

local utils = require("utils.lsp")
local jdtls = require("jdtls")
local cfg = utils.lang_server()
local home = vim.env.HOME

-- Workspace & JDTLS config
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/.local/share/jdtls/workspace/" .. project_name
local jdtls_config = home .. "/.local/share/jdtls/config_linux"

-- Dynamically find current Java
local java_home = vim.fn.trim(vim.fn.system("dirname $(dirname $(readlink -f $(which java)))"))

-- Dynamically find JDTLS launcher jar
local jdtls_base = vim.fn.trim(vim.fn.system("nix eval --raw nixpkgs#jdt-language-server"))

local launcher_glob = jdtls_base .. "/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"

local matches = vim.fn.glob(launcher_glob, true, true)
assert(#matches == 1, "jdtls launcher jar not found or ambiguous")

local jdtls_launcher = matches[1]

-- DAP/Test bundles
local bundles = {}
for _, pattern in ipairs({
	"/nix/store/*-vscode-java-test-*/server/*.jar",
	"/nix/store/*-vscode-java-debug-*/server/*.jar",
}) do
	for _, jar in ipairs(vim.fn.glob(pattern, true, true)) do
		table.insert(bundles, jar)
	end
end

require("jdtls.dap").setup_dap({ hotcodereplace = "auto" })

-- Auto-load coverage signs when entering a Java buffer, without running Maven
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.java",
	callback = function()
		local coverage = require("utils.java-code-coverage")
		local root = coverage.find_project_root()
		if root and vim.fn.filereadable(root .. "/target/site/jacoco/jacoco.xml") == 1 then
			coverage.parse_jacoco()
			coverage.show_signs()
		end
	end,
})

-- Keymap to regenerate coverage with Maven
vim.keymap.set("n", "<leader>jc", function()
	require("utils.java-code-coverage").refresh()
end, {})

cfg:add_server("jdtls", {
	cmd = {
		java_home .. "/bin/java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.level=ALL",
		"-Xmx1G",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		jdtls_launcher,
		"-configuration",
		jdtls_config,
		"-data",
		workspace_dir,
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "pom.xml", "build.gradle" }),
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
	flags = { allow_incremental_sync = true },
	init_options = { bundles = bundles, extendedClientCapabilities = jdtls.extendedClientCapabilities },
})

cfg:set_linters({ "java" }, { "checkstyle" })
cfg:set_formatters({ "java" }, { "google-java-format" })
cfg:set_indent({ "java" }, 2)

return cfg:get()
