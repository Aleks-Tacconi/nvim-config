local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)

-- Don't overwrite paste buffer when pasting
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Code Actions
vim.keymap.set("n", "<leader>c", vim.lsp.buf.code_action)

-- CMD enter command mode
vim.keymap.set("n", ";", ":")

-- Use control backspace to delete last word
vim.keymap.set('i', '<C-H>', '<C-W>', opts)
vim.keymap.set('c', '<C-H>', '<C-W>', opts)

-- Diagnostic features
vim.keymap.set('n', '<leader>p', function()
    vim.diagnostic.open_float(0, {
        scope = "line",
        focusable = false,
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = "",
    })
end, opts)

vim.keymap.set('n', '<leader>m', function()
    local current = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({virtual_text = not current})
    local status = current and "Disabled" or "Enabled"
    print("Inline diagnostics: " .. status)
end, opts)
