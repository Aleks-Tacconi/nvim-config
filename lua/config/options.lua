vim.g.have_nerd_font = true
vim.o.number = true
vim.o.laststatus = 3
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 1000
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.sidescrolloff = 10
vim.o.confirm = true
vim.o.wrap = false
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.spell = true
vim.o.spelllang = "en"
vim.o.spellfile = vim.fn.expand("~/.config/nvim/spell/en.utf-8.add")

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.opt.iskeyword:append("-")
vim.opt.fillchars:append({ eob = " " })
