---Configure diagnostics, LSP keymaps, and native language servers.
return {
	"neovim/nvim-lspconfig",
	dependencies = { "saghen/blink.cmp" },
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local utils = require("utils.lsp")
		local qmlls, qmlls_learning = utils.qml_servers()

		vim.diagnostic.config({
			severity_sort = true,
			float = { source = "if_many" },
			underline = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			},
			virtual_text = {
				source = true,
				spacing = 2,
			},
		})

		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
			callback = function(ev)
				local bufnr = ev.buf
				local picker = require("snacks").picker

				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buf = bufnr, desc = "Go to definition" })
				vim.keymap.set("n", "grr", picker.lsp_references, { buf = bufnr, desc = "Find references" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buf = bufnr, desc = "Hover docs" })
				vim.keymap.set("n", "gi", picker.lsp_implementations, { buf = bufnr, desc = "Go to implementation" })
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buf = bufnr, desc = "Rename symbol" })
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buf = bufnr, desc = "Code action" })
			end,
		})

		local servers = {
			clangd = {},
			cssls = {},
			docker_compose_language_service = {},
			dockerls = {},
			gopls = {},
			html = {
				filetypes = { "html", "htmldjango" },
			},
			jsonls = {},
			kotlin_lsp = {},
			lemminx = {},
			lua_ls = {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			},
			marksman = {},
			nil_ls = {},
			postgres_lsp = {},
			ty = {
				cmd = function(dispatchers, config)
					return vim.lsp.rpc.start({ utils.get_path("ty", config.root_dir), "server" }, dispatchers, {
						cwd = config.cmd_cwd,
						env = config.cmd_env,
						detached = config.detached,
					})
				end,
			},
			qmlls = qmlls,
			qmlls_learning = qmlls_learning,
			ruff = {
				on_init = function(client)
					client.server_capabilities.hoverProvider = false
				end,
				cmd = function(dispatchers, config)
					return vim.lsp.rpc.start({ utils.get_path("ruff", config.root_dir), "server" }, dispatchers, {
						cwd = config.cmd_cwd,
						env = config.cmd_env,
						detached = config.detached,
					})
				end,
			},
			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = { enable = true },
						},
						check = { command = "clippy" },
						procMacro = { enable = true },
					},
				},
			},
			tailwindcss = {},
			tsgo = { cmd = utils.tsgo_cmd },
		}

		for server, config in pairs(servers) do
			vim.lsp.config(server, config)
		end
		vim.lsp.enable(vim.tbl_keys(servers))
	end,
}
