local utils = require("utils.lsp")
local cfg = utils.lang_server()
local qml_root_markers = { ".qmlls.ini", "qmldir", "CMakeLists.txt", ".git" }
local learning_root = vim.fs.normalize(vim.env.HOME .. "/.config/quickshell/learning")

-- Merge both common QML import env vars into the one qmlls understands.
local function join_paths(paths)
	local merged = {}
	local seen = {}

	for _, value in ipairs(paths) do
		if value and value ~= "" then
			for _, path in ipairs(vim.split(value, ":", { plain = true, trimempty = true })) do
				if not seen[path] then
					seen[path] = true
					table.insert(merged, path)
				end
			end
		end
	end

	if #merged == 0 then
		return nil
	end

	return table.concat(merged, ":")
end

local function quickshell_qml_path()
	local matches = vim.fn.glob("/nix/store/*quickshell-wrapped-*/lib/qt-6/qml", true, true)
	return matches[1]
end

local function qml_import_path(extra_path)
	return join_paths({ vim.env.QML_IMPORT_PATH or "", vim.env.QML2_IMPORT_PATH or "", extra_path or "" })
end

local function qmlls_config(extra_path)
	local import_path = qml_import_path(extra_path)
	return {
		-- qmlls only reads import paths from QML_IMPORT_PATH when -E is enabled.
		cmd = import_path and { utils.get_path("qmlls"), "-E" } or { utils.get_path("qmlls") },
		cmd_env = import_path and { QML_IMPORT_PATH = import_path } or nil,
		workspace_required = true,
	}
end

cfg:add_server("qmlls", vim.tbl_extend("force", qmlls_config(), {
	root_markers = qml_root_markers,
}))

cfg:add_server("qmlls_learning", vim.tbl_extend("force", qmlls_config(quickshell_qml_path()), {
	filetypes = { "qml", "qmljs" },
	root_dir = function(bufnr, on_dir)
		local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
		if path == learning_root or vim.startswith(path, learning_root .. "/") then
			on_dir(learning_root)
			return
		end

		on_dir(nil)
	end,
}))
cfg:set_formatters({ "qml" }, { "qmlformat" })

return cfg:get()
