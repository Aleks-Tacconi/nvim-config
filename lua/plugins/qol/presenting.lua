return {
	"sotte/presenting.nvim",
	opts = {
		options = {
			width = 170,
		},
		keymaps = {
			["n"] = function()
				Presenting.next()
				vim.cmd("normal! G")
			end,
			["p"] = function()
				Presenting.prev()
				vim.cmd("normal! G")
			end,
			["<CR>"] = function()
				Presenting.next()
				vim.cmd("normal! G")
			end,
			["<BS>"] = function()
				Presenting.prev()
				vim.cmd("normal! G")
			end,
		},
	},
	cmd = { "Presenting" },
}
