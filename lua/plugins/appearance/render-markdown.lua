return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
        vim.keymap.set("n", "<leader>m", function() vim.cmd("RenderMarkdown toggle") end, {})
    end,
}
