return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "LspAttach",
	opts = {},
	keys = {
		{ "tt", "<cmd>Trouble diagnostics toggle<cr>" },
		{
			"tj",
			function()
				require("trouble").next({ mode = "diagnostics", skip_groups = true, jump = true })
			end,
		},
		{
			"tk",
			function()
				require("trouble").prev({ mode = "diagnostics", skip_groups = true, jump = true })
			end,
		},
	},
	config = function(_, opts)
		local trouble = require("trouble")
		trouble.setup(opts)

		-- vim.api.nvim_create_autocmd("DiagnosticChanged", {
		-- 	callback = function()
		-- 		local diags = vim.diagnostic.get(nil)
		-- 		if #diags > 0 then
		-- 			if not trouble.is_open() then
		-- 				trouble.open("diagnostics")
		-- 			end
		-- 		else
		-- 			if trouble.is_open() then
		-- 				trouble.close()
		-- 			end
		-- 		end
		-- 	end,
		-- })
	end,
}
