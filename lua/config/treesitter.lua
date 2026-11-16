---Install parsers and attach native highlighting to supported file buffers.
local M = {}

M.parsers = { "markdown", "markdown_inline", "html", "latex", "typst", "yaml", "rust", "ron", "python", "lua" }

local markdown_query_patched = false

---Keep Markdown code fence rows visible so render-markdown borders are not hidden.
local function patch_markdown_query()
	if markdown_query_patched then
		return
	end
	local files = vim.treesitter.query.get_files("markdown", "highlights")
	if #files == 0 then
		return
	end
	local queries = {}
	for _, path in ipairs(files) do
		local source = table.concat(vim.fn.readfile(path), "\n")
		queries[#queries + 1] = source:gsub('%(#set! conceal_lines ""%)', "")
	end
	vim.treesitter.query.set("markdown", "highlights", table.concat(queries, "\n"))
	markdown_query_patched = true
end

---Enable highlighting and optional Treesitter indentation for one buffer.
local function attach(buf, lang)
	if lang == "markdown" then
		patch_markdown_query()
	end
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
	patch_markdown_query()
	ts.install(M.parsers)
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
		callback = function(event)
			start(event.buf)
		end,
	})
end

return M
