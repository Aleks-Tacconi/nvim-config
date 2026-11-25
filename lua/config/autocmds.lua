---Register core Neovim autocommands.

local group = vim.api.nvim_create_augroup("core-autocmds", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "Highlight when yanking (copying) text",
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

local two_space_ft = {
	"c",
	"cpp",
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
	"json",
	"jsonc",
	"markdown",
	"nix",
	"xml",
}

local four_space_ext = {
	"ipynb",
}

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = two_space_ft,
	desc = "Configure buffer indentation width",
	callback = function(ev)
		local ext = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":e")
		local width = vim.list_contains(four_space_ext, ext) and 4 or 2
		vim.bo[ev.buf].expandtab = true
		vim.bo[ev.buf].tabstop = width
		vim.bo[ev.buf].shiftwidth = width
		vim.bo[ev.buf].softtabstop = width
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
	group = group,
	desc = "Enable relative line numbers in normal mode",
	callback = function()
		if vim.wo.nu and not vim.api.nvim_get_mode().mode:match("^[iRt]") then
			vim.wo.relativenumber = true
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
	group = group,
	desc = "Disable relative line numbers in insert/command mode or unfocused windows",
	callback = function()
		if vim.wo.nu then
			vim.wo.relativenumber = false
		end
	end,
})
