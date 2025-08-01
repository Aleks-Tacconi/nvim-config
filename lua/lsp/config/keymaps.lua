local M = {}

local function open_float()
	vim.diagnostic.open_float({
		border = "rounded",
		source = "if_many",
	})
end

function M.on_attach(_, bufnr)
	local builtin = require("telescope.builtin")

	vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = bufnr })
	vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = bufnr })
	vim.keymap.set("n", "K", function()
		vim.o.winborder = "single"
		vim.lsp.buf.hover()
	end, { buffer = bufnr })
	vim.keymap.set("n", "gi", builtin.lsp_implementations, { buffer = bufnr })
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
	vim.keymap.set("n", "<leader>p", open_float, { buffer = bufnr })
end

return M
