return {
	 "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 250,
    plugins = {
      spelling = {
        enabled = true,
        suggestions = 20,
      },
    },
    win = {
      no_overlap = false,
      row = -1,
      col = -1,
      width = { min = 100, max = 150 },
      height = { min = 8, max = 20 },
      border = "single",
      title = false,
      padding = { 1, 2 },
    },
    layout = {
      width = { min = 20, max = 50 },
      spacing = 3,
    },
    icons = {
      mappings = false,
    },
    spec = {
      { "<leader>b", group = "debug" },
      { "<leader>g", group = "git" },
      { "<leader>o", group = "opencode" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "toggle/trouble" },
      { "<leader>w", group = "watch" },
    },
  },
}