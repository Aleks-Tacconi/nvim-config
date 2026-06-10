vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_python3_provider = nil

if vim.env.NVIM_PYTHON_PROVIDER then
	vim.g.python3_host_prog = vim.env.NVIM_PYTHON_PROVIDER
	vim.env.PATH = vim.fn.fnamemodify(vim.env.NVIM_PYTHON_PROVIDER, ":h") .. ":" .. vim.env.PATH
end

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
