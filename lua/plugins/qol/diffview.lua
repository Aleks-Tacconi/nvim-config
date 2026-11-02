---Show native side-by-side diffs and return to normal browsing when Oil opens.
return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		enhanced_diff_hl = true,
		hooks = {
			view_opened = function(view)
				view.panel:close()
			end,
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("diffview-close-for-oil", { clear = true }),
			pattern = "oil://*",
			callback = function(event)
				local lib = package.loaded["diffview.lib"]
				if not lib or not lib.get_current_view() then
					return
				end
				local dir = require("oil").get_current_dir(event.buf)
				vim.schedule(function()
					if lib.get_current_view() then
						require("diffview").close()
						require("oil").open(dir)
					end
				end)
			end,
		})
	end,
}
