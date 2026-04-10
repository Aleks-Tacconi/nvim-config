local M = {}

---Return the Personal vocabulary directory used by Vale.
---@return string
local function vocab_dir()
	return vim.fn.expand("~/NixOSConfig/configuration/homemanagerconfig/vale/styles/config/vocabularies/Personal")
end

---Return the accept and reject vocabulary file paths.
---@return string, string
local function vocab_files()
	local base = vocab_dir()
	return base .. "/accept.txt", base .. "/reject.txt"
end

---Extract accepted and rejected spell entries from Neovim's spellfile.
---@return string[], string[]
local function parse_spellfile()
	local spellfile = vim.o.spellfile
	local words = {}
	local accepted = {}
	local rejected = {}

	if spellfile == "" or vim.fn.filereadable(spellfile) == 0 then
		return accepted, rejected
	end

	for _, line in ipairs(vim.fn.readfile(spellfile)) do
		if line ~= "" and not line:match("^#") and not line:match("^P%d+$") then
			local is_rejected = line:sub(-2) == "/!"
			local word = is_rejected and line:sub(1, -3) or line
			if word ~= "" then
				words[word] = is_rejected and "reject" or "accept"
			end
		end
	end

	for word, status in pairs(words) do
		if status == "reject" then
			table.insert(rejected, word)
		else
			table.insert(accepted, word)
		end
	end

	return accepted, rejected
end

---Write a sorted vocabulary file for Vale.
---@param path string
---@param words string[]
local function write_vocab(path, words)
	table.sort(words, function(a, b)
		return a:lower() < b:lower()
	end)
	vim.fn.writefile(words, path)
end

---Refresh lint diagnostics after updating the vocabulary.
local function refresh_lint()
	if vim.bo.filetype ~= "markdown" then
		return
	end

	pcall(function()
		require("lint").try_lint("vale")
	end)
end

---Sync Neovim's spellfile into Vale's Personal vocabulary.
function M.sync_from_spellfile()
	local accept_path, reject_path = vocab_files()
	vim.fn.mkdir(vocab_dir(), "p")
	local accepted, rejected = parse_spellfile()
	write_vocab(accept_path, accepted)
	write_vocab(reject_path, rejected)
	refresh_lint()
end

---Run a spell command and mirror the result into Vale's vocabulary.
---@param command string
function M.learn(command)
	vim.cmd("silent! normal! " .. command)
	M.sync_from_spellfile()
end

---Initialize Vale vocabulary syncing for the current Neovim session.
function M.setup()
	local group = vim.api.nvim_create_augroup("vale-spell-sync", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = M.sync_from_spellfile,
	})
end

return M
