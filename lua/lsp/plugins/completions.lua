return {
	"saghen/blink.cmp",

	dependencies = {
		"onsails/lspkind.nvim",
	},

	version = "1.*",
	opts = {
		keymap = {
			preset = "none",
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-y>"] = { "accept", "fallback" },
		},
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 0,
				window = {
					border = "single",
				},
			},
			ghost_text = { enabled = true },
			menu = {
				border = "single",
				draw = {
					columns = {
						{ "kind_icon", "kind", gap = 1 },
						{ "label", "label_description", gap = 3 },
					},
					components = {
						label = {
							text = function(ctx)
								return "│ " .. ctx.label
							end,
						},
					},
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
