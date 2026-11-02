---Load language tooling once for explicitly supported filetypes.
local languages = {
	c = { "c" },
	cpp = { "c" },
	css = { "css" },
	scss = { "css" },
	less = { "css" },
	dockerfile = { "docker" },
	["yaml.docker-compose"] = { "docker" },
	go = { "go" },
	gomod = { "go" },
	gowork = { "go" },
	gotmpl = { "go" },
	html = { "html" },
	htmldjango = { "html" },
	javascript = { "javascript" },
	javascriptreact = { "javascript" },
	typescript = { "javascript" },
	typescriptreact = { "javascript" },
	json = { "json" },
	jsonc = { "json" },
	kotlin = { "kotlin" },
	lua = { "lua" },
	markdown = { "markdown", "python" },
	quarto = { "markdown", "python" },
	nix = { "nix" },
	prolog = { "prolog" },
	python = { "python" },
	qml = { "qml" },
	qmljs = { "qml" },
	rust = { "rust" },
	sql = { "sql" },
	xml = { "xml" },
}

local loaded = {}

---Register a language module and allow failed imports to be retried.
local function load_file(name, keymaps)
	if loaded[name] then
		return
	end
	local module = "lsp.config.languages." .. name
	local ok, lang_config = pcall(require, module)
	if not ok then
		package.loaded[module] = nil
		vim.notify("lspconfig: error loading " .. name .. "\n" .. lang_config, vim.log.levels.ERROR)
		return
	end

	for server, config in pairs(lang_config.servers) do
		config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
		config.on_attach = keymaps.on_attach
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	end
	loaded[name] = true
end

---Register the tooling needed by a buffer filetype.
local function load_for_ft(ft, keymaps)
	local paths = languages[ft]
	if not paths then
		return
	end
	for _, path in ipairs(paths) do
		load_file(path, keymaps)
	end
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
	},
	event = { "BufReadPre", "BufNewFile", "VimEnter", "FileType" },
	config = function()
		require("lsp.config.diagnostics")
		local keymaps = require("lsp.config.keymaps")

		-- Load config for the filetype that triggered this event.
		local ft = vim.bo.filetype
		if ft ~= "" then
			load_for_ft(ft, keymaps)
		end

		-- Also handle any future filetype changes (e.g. new buffers opened later).
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("language-tooling", { clear = true }),
			callback = function(ev)
				local buf_ft = vim.bo[ev.buf].filetype
				if buf_ft ~= "" then
					load_for_ft(buf_ft, keymaps)
				end
			end,
		})
	end,
}
