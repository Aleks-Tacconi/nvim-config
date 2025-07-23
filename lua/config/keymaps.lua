local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap
local builtin = require("telescope.builtin")

local function oil()
	local cwd = vim.fn.getcwd()
	cwd = cwd .. "/"
	local path = vim.api.nvim_buf_get_name(0)
	path = path:gsub("^oil:///", "/")
	if path ~= cwd then
		vim.cmd("Oil")
	end
end

vim.keymap.set("n", "<leader>d", oil)

vim.keymap.set("n", "<leader>m", ":RenderMarkdown toggle<CR>")

vim.keymap.set("n", "<leader>sf", function()
	vim.o.winborder = "none"
	builtin.find_files()
end)
vim.keymap.set("n", "<leader>sg", function()
	vim.o.winborder = "none"
	builtin.live_grep()
end)
vim.keymap.set("n", "<leader>sd", function()
	vim.o.winborder = "none"
	builtin.diagnostics()
end)

local diagnostics_enabled = true
vim.keymap.set("n", "<leader>tl", function()
	diagnostics_enabled = not diagnostics_enabled
	if diagnostics_enabled then
		vim.diagnostic.enable()
	else
		vim.diagnostic.enable(false)
	end
end, opts)

keymap("i", "<C-H>", "<C-W>", opts)
keymap("c", "<C-H>", "<C-W>", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

keymap("v", "p", '"_dP', opts)
