local utils = require("utils.lsp")
local cfg = utils.lang_server()

---Resolve the TypeScript native LSP (`tsgo` or TS 7+ `tsc --lsp --stdio`).
local function resolve_tsgo_cmd(dispatchers, config)
	local root_dir = (config or {}).root_dir
	if root_dir then
		local local_tsgo = vim.fs.joinpath(root_dir, "node_modules/.bin/tsgo")
		if vim.fn.executable(local_tsgo) == 1 then
			return vim.lsp.rpc.start({ local_tsgo, "--lsp", "--stdio" }, dispatchers)
		end

		-- TypeScript 7+ ships the native LSP in `tsc --lsp --stdio` and omits `lib/tsserver.js`.
		local local_tsc = vim.fs.joinpath(root_dir, "node_modules/.bin/tsc")
		local tsserver = vim.fs.joinpath(root_dir, "node_modules/typescript/lib/tsserver.js")
		if vim.fn.executable(local_tsc) == 1 and not vim.uv.fs_stat(tsserver) then
			return vim.lsp.rpc.start({ local_tsc, "--lsp", "--stdio" }, dispatchers)
		end
	end

	return vim.lsp.rpc.start({ "tsgo", "--lsp", "--stdio" }, dispatchers)
end

cfg:add_server("tsgo", { cmd = resolve_tsgo_cmd })
cfg:add_server("tailwindcss", {})
cfg:set_formatters({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, { "oxfmt" })
cfg:set_linters({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, { "oxlint" })
cfg:set_indent({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, 2)

-- NOTE: to generate eslint_d config file:
-- npm init -y
-- npx eslint --init

return cfg:get()
