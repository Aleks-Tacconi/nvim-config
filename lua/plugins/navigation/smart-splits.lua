---Moves to the next Neovim split, then crosses into the next tmux pane.
local function next_context()
	local window = vim.fn.winnr()
	local window_count = vim.fn.winnr("$")

	if window < window_count then
		vim.cmd("wincmd w")
		return
	end

	vim.api.nvim_set_current_win(vim.fn.win_getid(1))
	if vim.env.TMUX then
		vim.system({ "tmux", "select-pane", "-t", ":.+" })
	end
end

return {
	"mrjones2014/smart-splits.nvim",
	lazy = false,
	config = function()
		require("smart-splits").setup({
			multiplexer_integration = "tmux",
		})

		vim.keymap.set({ "n", "t" }, "<C-s>", next_context, { desc = "Next Neovim or tmux pane" })

		if vim.env.TMUX then
			vim.system({
				"tmux",
				"bind-key",
				"-n",
				"C-s",
				"if",
				"-F",
				"#{@pane-is-vim}",
				"send-keys C-s",
				"select-pane -t :.+",
			}):wait()
		end
	end,
}
