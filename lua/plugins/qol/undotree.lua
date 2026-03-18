return {
	"mbbill/undotree",
	cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
	keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle undo tree" } },
}
