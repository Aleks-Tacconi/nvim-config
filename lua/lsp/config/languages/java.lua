local utils = require("utils.lsp")
local cfg = utils.lang_server()

local jdtls = require("jdtls")

local home = vim.env.HOME
local JDTLS_HOME = home .. "/.local/share/jdtls"

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/jdtls-workspace/" .. project_name

-- readlink -f $(which java)
-- nix eval --raw nixpkgs#jdt-language-server
-- ..                    #vscode-extensions.vscjava.vscode-java-debug
-- ..                    #vscode-extensions.vscjava.vscode-java-test

local bundles = {
	vim.fn.glob(
		"/nix/store/snzhiihk2gxwpri5624lav7bvsvks1b6-vscode-extension-vscjava-vscode-java-test-0.43.1/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar",
		true
	),
	vim.fn.glob(
		"/nix/store/mjcgc0313ldifhhb35z8d004680kazp8-vscode-extension-vscjava-vscode-java-debug-0.58.2025022807/share/vscode/extensions/vscjava.vscode-java-debug/server/*.jar",
		true
	),
}

cfg:add_server("jdtls", {
	cmd = {
		"/nix/store/5ig1bv8vkdqjw4ijma8q88bl0hrzbkbb-openjdk-24.0.2+12/lib/openjdk/bin/java",
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
		"/nix/store/wkyckfdj74z7gzk43fifla50vcyx3540-jdt-language-server-1.46.1/share/java/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar",
		"-configuration",
		JDTLS_HOME .. "/config_linux",
		"-data",
		workspace_dir,
	},

	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "pom.xml", "build.gradle" }),

	settings = {
		java = {
			eclipse = {
				downloadSources = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-24",
						path = "/nix/store/5ig1bv8vkdqjw4ijma8q88bl0hrzbkbb-openjdk-24.0.2+12/lib/openjdk/",
					},
				},
			},
			maven = {
				downloadSources = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			signatureHelp = { enabled = true },
			format = {
				enabled = true,
			},
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
				importOrder = {
					"java",
					"javax",
					"com",
					"org",
				},
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				useBlocks = true,
			},
		},
	},
	flags = {
		allow_incremental_sync = true,
	},
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
	},
})

cfg:set_linters({ "java" }, { "checkstyle" })
cfg:set_formatters({ "java" }, { "google-java-format" })
cfg:set_indent({ "java" }, 2)

return cfg:get()
