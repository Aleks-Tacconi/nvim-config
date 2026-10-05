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

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		vim.o.winborder = "single"
	end,
})

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

map("n", "<leader>p", function()
	vim.diagnostic.open_float({
		border = "rounded",
		source = "if_many",
	})
end, "Line diagnostics")

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
map("n", "<C-l>", ":cnext<CR>", "Next quickfix item")
map("n", "<C-h>", ":cprev<CR>", "Previous quickfix item")

-- work for any upper/lower-case variant of cmds table
local cmds = { "w", "q", "wq", "wqa", "wa" }
for _, cmd in ipairs(cmds) do
    local variants = { cmd:upper() }
    for i = 1, #cmd do
        local variant = cmd:sub(1, i):upper() .. cmd:sub(i + 1)
        table.insert(variants, variant)
    end

    for _, v in ipairs(variants) do
        vim.api.nvim_create_user_command(v, cmd, {})
    end
end
