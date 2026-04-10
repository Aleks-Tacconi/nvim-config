local M = {}

local function open_float()
    vim.diagnostic.open_float({
        border = "rounded",
        source = "if_many",
    })
end

function M.on_attach(_, bufnr)
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = bufnr, desc = "Go to definition" })
    vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = bufnr, desc = "Find references" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover docs" })
    vim.keymap.set("n", "gi", builtin.lsp_implementations, { buffer = bufnr, desc = "Go to implementation" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
    vim.keymap.set("n", "<leader>p", open_float, { buffer = bufnr, desc = "Line diagnostics" })
end

return M
