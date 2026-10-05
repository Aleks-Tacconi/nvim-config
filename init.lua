local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("config/globals")
require("config/compat")
require("config/options")
require("config/filetypes")
require("config/autocmds")
require("config/commands")
require("lazy").setup({
	{ import = "lsp/plugins" },
	{ import = "plugins/qol" },
	{ import = "plugins/navigation" },
	{ import = "plugins/appearance" },
})
require("config/keymaps")
