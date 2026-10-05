local function map(mode, lhs, rhs, desc, extra_opts)
	local opts = vim.tbl_extend("force", {
		noremap = true,
		silent = true,
		desc = desc,
	}, extra_opts or {})

	vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "z=", function()
	require("config.telescope").spell_suggestions()
end, "Spell suggestions")

local feed = function(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "",
        false)
end

map("n", "zg", function()
	require("utils.vale").learn("zg")
	feed("a")
	feed("<Esc>")
end, "Add word to dictionary")

map("n", "zw", function()
	require("utils.vale").learn("zw")
	feed("a")
	feed("<Esc>")
end, "Mark word as wrong")

local function oil()
	local cwd = vim.fn.getcwd()
	cwd = cwd .. "/"
	local path = vim.api.nvim_buf_get_name(0)
	path = path:gsub("^oil:///", "/")
	if path ~= cwd then
		vim.cmd("Oil")
	end
end

map("n", "<leader>d", oil, "Open Oil")

local diagnostics_enabled = true
map("n", "<leader>tl", function()
	diagnostics_enabled = not diagnostics_enabled
	if diagnostics_enabled then
		vim.diagnostic.enable()
	else
		vim.diagnostic.enable(false)
	end
end, "Toggle diagnostics")

map("i", "<C-H>", "<C-W>", "Delete previous word")
map("i", "<C><BS>", "<C-W>", "Delete previous word")
map("c", "<C-H>", "<C-W>", "Delete previous word")
map("c", "<C><BS>", "<C-W>", "Delete previous word")

map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-j>", "<C-w>j", "Move to lower window")
map("n", "<C-k>", "<C-w>k", "Move to upper window")
map("n", "<C-l>", "<C-w>l", "Move to right window")

map("v", "<", "<gv", "Indent left and keep selection")
map("v", ">", ">gv", "Indent right and keep selection")

map("v", "<A-j>", ":m .+1<CR>==", "Move selection down")
map("v", "<A-k>", ":m .-2<CR>==", "Move selection up")
map("x", "J", ":move '>+1<CR>gv-gv", "Move block down")
map("x", "K", ":move '<-2<CR>gv-gv", "Move block up")
map("x", "<A-j>", ":move '>+1<CR>gv-gv", "Move block down")
map("x", "<A-k>", ":move '<-2<CR>gv-gv", "Move block up")

map("v", "p", '"_dP', "Paste without yanking")
