---Configure Oil directory navigation.
local always_hidden = {
	[".DS_Store"] = true,
	[".git"] = true,
	[".mypy_cache"] = true,
	[".pytest_cache"] = true,
	[".ruff_cache"] = true,
	["__pycache__"] = true,
}

return {
	"stevearc/oil.nvim",
	cmd = { "Oil" },
	init = function()
		if vim.fn.argc() > 0 then
			for i = 0, vim.fn.argc() - 1 do
				if vim.fn.isdirectory(vim.fn.argv(i)) == 1 then
					require("oil")
					break
				end
			end
		end
	end,
	opts = {
		view_options = {
			show_hidden = true,
			is_always_hidden = function(name, _)
				return always_hidden[name] or name:match("%.pyc$") ~= nil
			end,
		},
	},
}
