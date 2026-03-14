return {
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		cmd = "Copilot",
		opts = {
			panel = { enabled = false },
			suggestion = { enabled = false },
		},
	},
	{
		"saghen/blink.cmp",
		optional = true,
		dependencies = { "fang2hou/blink-copilot" },
		opts = function(_, opts)
			opts.sources = opts.sources or {}
			opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }

			if not vim.tbl_contains(opts.sources.default, "copilot") then
				table.insert(opts.sources.default, "copilot")
			end

			opts.sources.providers = opts.sources.providers or {}
			opts.sources.providers.copilot = {
				name = "copilot",
				module = "blink-copilot",
				score_offset = 100,
				async = true,
			}
		end,
	},
}
