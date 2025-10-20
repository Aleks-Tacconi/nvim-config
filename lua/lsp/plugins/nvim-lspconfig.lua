require("lsp.config.diagnostics")

local keymaps = require("lsp.config.keymaps")
local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/lsp/config/languages/*.lua", true, true)
local servers = {}

for _, file in ipairs(files) do
	local lang_config = dofile(file)
	for server, config in pairs(lang_config.servers) do
		config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
		config.on_attach = keymaps.on_attach

		servers[server] = config
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	end
end

return {
	"neovim/nvim-lspconfig",
	{ "j-hui/fidget.nvim", opts = { notification = {
		override_vim_notify = true,
	} } },
	"saghen/blink.cmp",

	opts = {
		servers = servers,
	},
}
