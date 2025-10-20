local utils = require("utils.lsp")
local cfg = utils.lang_server()

local home = vim.env.HOME
local jdtls = require("jdtls")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/jdtls-workspace/" .. project_name
local JDTLS_HOME = home .. "/.local/share/jdtls"

-- readlink -f $(which java)
-- nix eval --raw nixpkgs#jdt-language-server

local bundles = {}
vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/.local/share/nvim/mason/share/java-test/*.jar", 1), "\n"))

cfg:add_server("jdtls", {
	cmd = {
		"/nix/store/7q3rrp1i89mgkqghd2d1yrr32xqz8g6w-openjdk-23.0.2+7/lib/openjdk/bin/java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-javaagent:" .. "/nix/store/1vmbvcmr7q6vjdas6pnwbdy1q9c2hwrj-lombok-1.18.38/share/java/lombok.jar",
		"-Xmx4g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		"/nix/store/xrcbdqrzh0xbjr3rqal4vssmgvh9gpr7-jdt-language-server-1.46.1/share/java/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar",
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
				-- TODO Update this by adding any runtimes that you need to support your Java projects and removing any that you don't have installed (ls /usr/bin/jvm)
				runtimes = {
					{
						name = "JavaSE-23",
						path = "/nix/store/7q3rrp1i89mgkqghd2d1yrr32xqz8g6w-openjdk-23.0.2+7/lib/openjdk/bin/java",
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

return cfg:get()
