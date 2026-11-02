---Install parsers and attach native highlighting to supported file buffers.
local M = {}

M.parsers = { "markdown", "markdown_inline", "html", "latex", "typst", "yaml", "rust", "ron", "python", "lua" }

---Enable highlighting and optional Treesitter indentation for one buffer.
local function attach(buf, lang)
	vim.treesitter.start(buf, lang)
	if vim.bo[buf].filetype ~= "typescript" and vim.bo[buf].filetype ~= "typescriptreact" then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

---Install a missing parser before enabling its buffer features.
local function start(buf)
	if vim.bo[buf].buftype ~= "" then
		return
	end
	local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
	if not lang or not require("nvim-treesitter.parsers")[lang] then
		return
	end

	local ts = require("nvim-treesitter")
	if vim.tbl_contains(ts.get_installed("parsers"), lang) then
		attach(buf, lang)
		return
	end
	ts.install({ lang }):await(function(err, success)
		vim.schedule(function()
			if
				not err
				and success
				and vim.api.nvim_buf_is_valid(buf)
				and vim.treesitter.language.get_lang(vim.bo[buf].filetype) == lang
			then
				attach(buf, lang)
			end
		end)
	end)
end

---Register highlighting and install the parsers used by notebooks.
function M.setup()
	local ts = require("nvim-treesitter")
	ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
	ts.install(M.parsers)
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
		callback = function(event)
			start(event.buf)
		end,
	})
end

return M
