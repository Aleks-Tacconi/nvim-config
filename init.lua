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

-- Highlight text when yanking (copying)
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

require("config/globals")
require("config/options")
require("lazy").setup({
	{ import = "lsp/plugins" },
	{ import = "plugins/qol" },
	{ import = "plugins/navigation" },
	{ import = "plugins/appearance" },
})
require("config/keymaps")

-- load harpoon buffers
local harpoon = require("harpoon")
local marks = harpoon:list().items
local current_buf = vim.api.nvim_get_current_buf()

for _, mark in ipairs(marks) do
	local file_path = mark.value
	vim.cmd("edit " .. vim.fn.fnameescape(file_path))
end

vim.api.nvim_set_current_buf(current_buf)
