return {
	dir = "/home/aleks/ai-nvim",
	name = "ai-nvim",
	build = ":UpdateRemotePlugins",
	config = function()
		vim.g.python3_host_prog = "/home/aleks/ai-nvim/.venv/bin/python"
	end,
}
