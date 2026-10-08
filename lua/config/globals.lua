vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_python3_provider = nil

if vim.env.NVIM_PYTHON_PROVIDER then
	vim.g.python3_host_prog = vim.env.NVIM_PYTHON_PROVIDER
	vim.env.PATH = vim.fn.fnamemodify(vim.env.NVIM_PYTHON_PROVIDER, ":h") .. ":" .. vim.env.PATH
end

if vim.fn.executable("magick") ~= 1 then
	local magick_bin = "/nix/store/s13s3r3pi67vj27s6ca7pbrxs2z4zjf6-imagemagick-7.1.2-31/bin"
	if vim.fn.isdirectory(magick_bin) == 1 then
		vim.env.PATH = magick_bin .. ":" .. vim.env.PATH
	end
end

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
