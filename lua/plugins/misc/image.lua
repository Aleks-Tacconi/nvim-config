return {
	"3rd/image.nvim",
	event = "VeryLazy",
	config = function()
		require("image").setup({
			backend = "kitty",
		})
	end,
}
