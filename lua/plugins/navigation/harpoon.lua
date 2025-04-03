return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	lazy = false,
	requires = { "nvim-lua/plenary.nvim" },
	config = function()
		require("harpoon").setup({})
	end,
	keys = {
		{
			"<leader>a",
			function()
				require("harpoon"):list():add()
                vim.cmd("w")
                vim.cmd("e")
			end,
			desc = "harpoon file",
		},
		{
			"<leader>h",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "[S]earch [H]arpoon",
		},
		{
			"<leader>1",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "harpoon to file 1",
		},
		{
			"<leader>2",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "harpoon to file 2",
		},
		{
			"<leader>3",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "harpoon to file 3",
		},
		{
			"<leader>4",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "harpoon to file 4",
		},
		{
			"<leader>5",
			function()
				require("harpoon"):list():select(5)
			end,
			desc = "harpoon to file 5",
		},
		{
			"<leader>6",
			function()
				require("harpoon"):list():select(6)
			end,
			desc = "harpoon to file 6",
		},
		{
			"<leader>7",
			function()
				require("harpoon"):list():select(7)
			end,
			desc = "harpoon to file 7",
		},
	},
}
