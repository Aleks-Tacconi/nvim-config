return {
	"nvim-neo-tree/neo-tree.nvim",

	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},

	config = function()
		local neotree = require("neo-tree")
		local show_hidden = false

		local function is_neotree_open()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				local name = vim.api.nvim_buf_get_name(buf)

				if name:match("neo%-tree") then
					return true
				end
			end
			return false
		end

		neotree.setup({
			event_handlers = {
				{
					event = "file_opened",
					handler = function(_)
						require("neo-tree").close_all()
					end,
				},
			},
			filesystem = {
				filtered_items = {
					visible = show_hidden,
					hide_dotfiles = not show_hidden,
					hide_hidden = not show_hidden,
				},
			},
		})

		vim.keymap.set("n", "<Leader>d", function()
			if is_neotree_open() then
				show_hidden = not show_hidden
				neotree.setup({
					filesystem = {
						filtered_items = {
							visible = show_hidden,
							hide_dotfiles = not show_hidden,
							hide_hidden = not show_hidden,
						},
					},
				})
			end

			vim.cmd("Neotree filesystem reveal left")
		end)
	end,
}
