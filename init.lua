-- Install lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Highlight text when yanking (copying)
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Open pdfs in browser
vim.api.nvim_create_autocmd("BufRead", {
  pattern = "*.pdf",
  callback = function()
    local file = vim.fn.expand("%:p")
    if file ~= "" then
      vim.fn.system("brave '" .. file .. "' &")
    end
  end,
})

require("config/options")
require("config/keymaps")

require("lazy").setup({
	{ import = "plugins/appearance" },
	{ import = "plugins/lsp-config" },
	{ import = "plugins/navigation" },
	{ import = "plugins/misc" },
})

local current_buf = vim.api.nvim_get_current_buf()
local harpoon = require("harpoon")
local marks = harpoon:list().items
for _, mark in ipairs(marks) do
	local file_path = mark.value
	vim.cmd("edit " .. vim.fn.fnameescape(file_path))
end
vim.api.nvim_set_current_buf(current_buf)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "single",
})
vim.api.nvim_set_hl(0, "StatusLine", { bg = "#0e0e0e", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "#0e0e0e", fg = "#666666" })
