local lang_configs = require("lsp.config.languages.init")
local keymaps = require("lsp.config.keymaps")

require("lsp.config.diagnostics")

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {
				ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
			},
		},
		{ "j-hui/fidget.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"saghen/blink.cmp",
	},

	opts = {
		servers = lang_configs.servers,
	},

	config = function(_, opts)
		local ensure_installed = vim.tbl_flatten({ vim.tbl_keys(opts.servers), lang_configs.tools })

		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
		})

		for server, config in pairs(opts.servers) do
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			config.on_attach = keymaps.on_attach
            vim.lsp.config(server, config)
            vim.lsp.enable(server)
		end
	end,
}
