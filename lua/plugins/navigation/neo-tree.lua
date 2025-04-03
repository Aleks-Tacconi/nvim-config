return {
	"nvim-neo-tree/neo-tree.nvim",

	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		"xiyaowong/transparent.nvim",
	},

	config = function()
		require("neo-tree").setup({
			event_handlers = {
				{
					event = "file_opened",
					handler = function(_)
						require("neo-tree").close_all()
					end,
				},
			},
		})

		local function OpenNeoTree()
			vim.cmd("Neotree filesystem reveal left")
			vim.cmd("TransparentEnable")
		end

		vim.keymap.set("n", "<Leader>d", OpenNeoTree)
	end,
}
