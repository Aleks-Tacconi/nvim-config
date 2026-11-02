---Review unified Git diffs using native buffers and the shared picker.
return {
	"kokusenz/deltaview.nvim",
	keys = {
		{ "<leader>v", "<cmd>DeltaView<cr>", desc = "View file diff" },
	},
	opts = {
		fzf_picker = "ui_select",
		keyconfig = { dv_toggle_keybind = "" },
	},
}
