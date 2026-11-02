---Show undo history without opening the diff panel.
return {
	"mbbill/undotree",
	init = function()
		vim.g.undotree_DiffAutoOpen = 0
	end,
	cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
	keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle undo tree" } },
}
