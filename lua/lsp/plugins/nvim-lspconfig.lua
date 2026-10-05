-- Map from filetype to language config file paths.
-- This avoids dofile-ing every language config on every BufReadPre.
local ft_to_files = {}
do
	local config_dir = vim.fn.stdpath("config") .. "/lua/lsp/config/languages/"
	-- Each file is named after the language, but we need to know which
	-- filetypes each file covers without executing it.
	-- Convention: the basename (minus .lua) is a reliable ft hint.
	-- We build a lazy map: when a ft is first seen we load only that file.
	for _, path in ipairs(vim.fn.glob(config_dir .. "*.lua", true, true)) do
		-- register each file under its basename as a ft key (best-effort)
		local key = vim.fn.fnamemodify(path, ":t:r")
		ft_to_files[key] = { path }
	end
	-- extra aliases that don't match the filename
	ft_to_files["javascriptreact"] = { ft_to_files["javascript"][1] }
	ft_to_files["typescript"]      = { ft_to_files["javascript"][1] }
	ft_to_files["typescriptreact"] = { ft_to_files["javascript"][1] }
	ft_to_files["jsonc"]           = { ft_to_files["json"][1] }
	ft_to_files["htmldjango"]      = { ft_to_files["html"][1] }
	ft_to_files["cpp"]             = { ft_to_files["c"][1] }
	ft_to_files["rust"]            = { ft_to_files["c"][1] }
	ft_to_files["markdown"]        = { ft_to_files["markdown"][1], ft_to_files["python"][1] }
	ft_to_files["quarto"]          = { ft_to_files["markdown"][1], ft_to_files["python"][1] }
end

local loaded = {}

local function load_file(path, keymaps)
	if not path or loaded[path] then
		return
	end
	loaded[path] = true

	local ok, lang_config = pcall(dofile, path)
	if not ok then
		vim.notify("lspconfig: error loading " .. path .. "\n" .. lang_config, vim.log.levels.ERROR)
		return
	end

	for server, config in pairs(lang_config.servers) do
		config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
		config.on_attach = keymaps.on_attach
		vim.lsp.config(server, config)
		vim.lsp.enable(server)
	end
end

local function load_for_ft(ft, keymaps)
	local paths = ft_to_files[ft]
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
		{ "j-hui/fidget.nvim", opts = { notification = { override_vim_notify = true } } },
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
		vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
			callback = function(ev)
				local buf_ft = vim.bo[ev.buf].filetype
				if buf_ft ~= "" then
					load_for_ft(buf_ft, keymaps)
				end
			end,
		})

		vim.schedule(function()
			local current_ft = vim.bo.filetype
			if current_ft ~= "" then
				load_for_ft(current_ft, keymaps)
			end
		end)
	end,
}
