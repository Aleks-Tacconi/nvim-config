---Bootstrap plugins and load the editor configuration.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Failed to clone lazy.nvim into " .. lazypath)
	end
end
vim.opt.rtp:prepend(lazypath)

require("config.globals")
require("config.options")
require("config.filetypes")
require("config.autocmds")
require("lazy").setup({
	{ import = "lsp.plugins" },
	{ import = "plugins.qol" },
	{ import = "plugins.navigation" },
	{ import = "plugins.appearance" },
})
require("config.keymaps")
