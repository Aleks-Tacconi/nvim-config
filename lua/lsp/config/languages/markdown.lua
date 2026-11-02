local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("marksman", {})

-- cfg:set_linters({ "markdown" }, { "markdownlint" })
cfg:set_formatters({ "markdown", "quarto" }, { "prettier_markdown", "injected" })

---Use Python indentation in notebooks and two spaces in regular Markdown.
local function set_indent(buf)
	local width = vim.endswith(vim.api.nvim_buf_get_name(buf), ".ipynb") and 4 or 2
	vim.bo[buf].expandtab = true
	vim.bo[buf].shiftwidth = width
	vim.bo[buf].tabstop = width
	vim.bo[buf].softtabstop = width
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
	callback = function(event)
		if vim.bo[event.buf].filetype == "markdown" then
			set_indent(event.buf)
		end
	end,
})
if vim.bo.filetype == "markdown" then
	set_indent(0)
end

return cfg:get()
