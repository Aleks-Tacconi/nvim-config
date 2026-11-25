---Register editor and quickfix shortcuts.

---Map a shortcut with a description and shared options.
local function map(mode, lhs, rhs, desc, extra_opts)
	local opts = vim.tbl_extend("force", {
		silent = true,
		desc = desc,
	}, extra_opts or {})

	vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "z=", function()
	require("snacks").picker.spelling()
end, "Spell suggestions")

---Open Oil or step up to the parent directory until reaching the working directory.
local function oil()
	local cwd = vim.fn.getcwd():gsub("/+$", "") .. "/"
	local path = vim.api.nvim_buf_get_name(0):gsub("^oil:///", "/")
	if path ~= cwd then
		vim.cmd("Oil")
	end
end

map("n", "<leader>d", oil, "Open Oil")

map("n", "<leader>tl", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, "Toggle diagnostics")

map("n", "<leader>p", function()
	vim.diagnostic.open_float({
		source = "if_many",
	})
end, "Line diagnostics")

map("i", "<C-H>", "<C-W>", "Delete previous word")
map("i", "<C-BS>", "<C-W>", "Delete previous word")
map("c", "<C-H>", "<C-W>", "Delete previous word", { silent = false })
map("c", "<C-BS>", "<C-W>", "Delete previous word", { silent = false })

map("v", "<", "<gv", "Indent left and keep selection")
map("v", ">", ">gv", "Indent right and keep selection")

map("x", "J", ":move '>+1<CR>gv=gv", "Move block down")
map("x", "K", ":move '<-2<CR>gv=gv", "Move block up")
map("x", "<A-j>", ":move '>+1<CR>gv=gv", "Move block down")
map("x", "<A-k>", ":move '<-2<CR>gv=gv", "Move block up")

map("v", "p", '"_dP', "Paste without yanking")

map("n", "<C-l>", ":cnext<CR>", "Next quickfix item")
map("n", "<C-h>", ":cprev<CR>", "Previous quickfix item")
map("n", "<leader>u", function()
	vim.cmd.packadd("nvim.undotree")
	vim.cmd.Undotree()
end, "Toggle undo tree")

map("n", "<leader>h", function()
	require("utils.harpoon").toggle_menu()
end, "Harpoon menu")
map("n", "<leader>a", function()
	require("utils.harpoon").add()
end, "Harpoon add file")
for i = 1, 8 do
	map("n", "<leader>" .. i, function()
		require("utils.harpoon").select(i)
	end, "Harpoon file " .. i)
end
