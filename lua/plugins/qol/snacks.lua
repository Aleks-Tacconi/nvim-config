---Provide pickers, dialogs, notifications, and LazyGit.

---Read Git status once per file picker, including untracked files.
local function git_file_status(opts)
	local snacks = require("snacks")
	local root = snacks.git.get_root(opts.cwd or vim.fn.getcwd())
	if not root then
		return
	end
	local result = vim.system({
		"git", "status", "--porcelain=v1", "-z", "--untracked-files=all", "--no-renames",
	}, { cwd = root }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR)
		return
	end
	local statuses = {}
	for record in vim.gsplit(result.stdout, "\0", { plain = true, trimempty = true }) do
		statuses[vim.fs.normalize(root .. "/" .. record:sub(4))] = record:sub(1, 2)
	end
	---Attach Git status for Snacks' built-in file icons and highlights.
	opts.transform = function(item)
		item.status = statuses[snacks.picker.util.path(item)]
	end
end

return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	keys = {
		{
			"<leader>lg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Open LazyGit",
		},
		{
			"<leader>sf",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find files",
		},
		{
			"<leader>sg",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>sd",
			function()
				require("snacks").picker.diagnostics()
			end,
			desc = "Search diagnostics",
		},
	},
	opts = {
		input = {},
		lazygit = {
			win = { width = 0, height = 0, border = "none" },
		},
		notifier = { enabled = true },
		picker = {
			prompt = " ",
            frecency = true,
			layout = { preset = "fullscreen" },
			layouts = {
				fullscreen = {
					preset = "ivy",
					layout = {
						width = 0,
						height = 0,
						row = 0,
						border = { "", "", "", "", "", "", "", " " },
					},
					---Remove the filename title from the side-by-side preview.
					config = function(layout)
						layout.layout[2][2].title = ""
					end,
				},
			},
			sources = {
				files = { config = git_file_status },
				diagnostics = { filter = { cwd = false } },
			},
		},
	},
}
