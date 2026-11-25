---Resolve project executables and language-specific environment paths.
local M = {}

local _poetry_cache = {}
local _quickshell_path
local qml_root_markers = { ".qmlls.ini", "qmldir", "CMakeLists.txt", ".git" }
local learning_root = vim.fs.normalize(vim.env.HOME .. "/.config/quickshell/learning")

---Return true when `root` uses Poetry (`poetry.lock` or `[tool.poetry]` in `pyproject.toml`).
local function is_poetry_project(root)
	if vim.fn.filereadable(root .. "/poetry.lock") == 1 then
		return true
	end
	local pyproject = root .. "/pyproject.toml"
	if vim.fn.filereadable(pyproject) == 0 then
		return false
	end
	for _, line in ipairs(vim.fn.readfile(pyproject)) do
		if line:match("^%s*%[tool%.poetry") then
			return true
		end
	end
	return false
end

---Find a Poetry environment once per project, when Poetry is available.
local function poetry_bin_dir(root)
	if _poetry_cache[root] == nil then
		_poetry_cache[root] = ""
		if vim.fn.executable("poetry") == 1 and is_poetry_project(root) then
			local result = vim.system({ "poetry", "env", "info", "-p" }, { cwd = root, text = true }):wait()
			local path = vim.trim(result.stdout)
			if result.code == 0 and path ~= "" then
				_poetry_cache[root] = path .. "/bin/"
			end
		end
	end
	return _poetry_cache[root]
end

---Resolve a project executable, falling back to PATH or its command name.
function M.get_path(executable, path)
	path = path or vim.api.nvim_buf_get_name(0)
	local start = path ~= "" and path or vim.fn.getcwd()
	local root = vim.fs.root(start, { { "pyproject.toml", ".git", ".venv", "venv", "requirements.txt", "setup.py" } })
	root = root or (vim.fn.isdirectory(start) == 1 and start or vim.fs.dirname(start))

	for _, base in ipairs({ root .. "/.venv/bin/", root .. "/venv/bin/" }) do
		local full_path = base .. executable
		if vim.fn.executable(full_path) == 1 then
			return full_path
		end
	end

	local poetry_dir = poetry_bin_dir(root)
	if poetry_dir ~= "" then
		local full_path = poetry_dir .. executable
		if vim.fn.executable(full_path) == 1 then
			return full_path
		end
	end

	local resolved = vim.fn.exepath(executable)
	return resolved ~= "" and resolved or executable
end

---Resolve the TypeScript native LSP (`tsgo` or TS 7+ `tsc --lsp --stdio`).
function M.tsgo_cmd(dispatchers, config)
	config = config or {}
	local rpc_opts = {
		cwd = config.cmd_cwd,
		env = config.cmd_env,
		detached = config.detached,
	}
	local root_dir = config.root_dir
	if root_dir then
		local local_tsgo = vim.fs.joinpath(root_dir, "node_modules/.bin/tsgo")
		if vim.fn.executable(local_tsgo) == 1 then
			return vim.lsp.rpc.start({ local_tsgo, "--lsp", "--stdio" }, dispatchers, rpc_opts)
		end

		local local_tsc = vim.fs.joinpath(root_dir, "node_modules/.bin/tsc")
		local tsserver = vim.fs.joinpath(root_dir, "node_modules/typescript/lib/tsserver.js")
		if vim.fn.executable(local_tsc) == 1 and not vim.uv.fs_stat(tsserver) then
			return vim.lsp.rpc.start({ local_tsc, "--lsp", "--stdio" }, dispatchers, rpc_opts)
		end
	end

	return vim.lsp.rpc.start({ "tsgo", "--lsp", "--stdio" }, dispatchers, rpc_opts)
end

---Merge colon-separated QML import path strings without duplicates.
local function join_paths(paths)
	local merged, seen = {}, {}
	for _, value in ipairs(paths) do
		if value and value ~= "" then
			for _, path in ipairs(vim.split(value, ":", { plain = true, trimempty = true })) do
				if not seen[path] then
					seen[path] = true
					merged[#merged + 1] = path
				end
			end
		end
	end
	return #merged > 0 and table.concat(merged, ":") or nil
end

---Locate the Quickshell QML module directory in `/nix/store` once on demand.
local function quickshell_qml_path()
	if _quickshell_path == nil then
		local matches = vim.fn.glob("/nix/store/*quickshell-wrapped-*/lib/qt-6/qml", true, true)
		_quickshell_path = matches[1] or false
	end
	return _quickshell_path or nil
end

---Build a `qmlls` command and environment with optional extra QML import paths.
local function qmlls_base(extra_path)
	local import_path = join_paths({ vim.env.QML_IMPORT_PATH or "", vim.env.QML2_IMPORT_PATH or "", extra_path or "" })
	return {
		cmd = import_path and { "qmlls", "-E" } or { "qmlls" },
		cmd_env = import_path and { QML_IMPORT_PATH = import_path } or nil,
		workspace_required = true,
	}
end

---Return the standard `qmlls` and Quickshell `qmlls_learning` server configs.
function M.qml_servers()
	local qmlls = vim.tbl_extend("force", qmlls_base(), {
		root_markers = qml_root_markers,
		root_dir = function(bufnr, on_dir)
			local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
			if path ~= learning_root and not vim.startswith(path, learning_root .. "/") then
				on_dir(vim.fs.root(bufnr, qml_root_markers))
				return
			end
			on_dir(nil)
		end,
	})

	local qmlls_learning = {
		filetypes = { "qml", "qmljs" },
		workspace_required = true,
		cmd = function(dispatchers, config)
			local resolved = qmlls_base(quickshell_qml_path())
			local env = vim.tbl_extend("force", config.cmd_env or {}, resolved.cmd_env or {})
			return vim.lsp.rpc.start(resolved.cmd, dispatchers, {
				cwd = config.cmd_cwd,
				env = next(env) and env or nil,
				detached = config.detached,
			})
		end,
		root_dir = function(bufnr, on_dir)
			local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
			if path == learning_root or vim.startswith(path, learning_root .. "/") then
				on_dir(learning_root)
				return
			end
			on_dir(nil)
		end,
	}

	return qmlls, qmlls_learning
end

return M
