---Attach buffer-local language-server shortcuts.
local M = {}

---Show diagnostics for the current line.
local function open_float()
    vim.diagnostic.open_float({
        border = "rounded",
        source = "if_many",
    })
end

---Register language navigation and actions for an attached buffer.
function M.on_attach(_, bufnr)
    local picker = require("snacks").picker

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buf = bufnr, desc = "Go to definition" })
    vim.keymap.set("n", "gr", picker.lsp_references, { buf = bufnr, desc = "Find references" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buf = bufnr, desc = "Hover docs" })
    vim.keymap.set("n", "gi", picker.lsp_implementations, { buf = bufnr, desc = "Go to implementation" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buf = bufnr, desc = "Rename symbol" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buf = bufnr })
    vim.keymap.set("n", "<leader>p", open_float, { buf = bufnr, desc = "Line diagnostics" })
end

return M
