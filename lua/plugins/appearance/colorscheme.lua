return {
	"Mofiqul/vscode.nvim",
	config = function()
		require("vscode").setup()
		vim.cmd("colorscheme vscode")

		local bg = "#0e0e0e"
		local grey_1 = "#333333"
		local grey_2 = "#171717"

		vim.api.nvim_set_hl(0, "BufferLineFill", { bg = bg })

		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = grey_1, fg = grey_1 })
		vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = grey_1, fg = "#ffffff", bold = true })
		vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#ffffff" })
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = grey_2, fg = grey_2 })
		vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = grey_2, fg = "#ffffff" })
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = grey_2, fg = "#333333" })
		vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = grey_2 })
		vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = grey_1 })
		vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = "#ffffff", bold = true })
		vim.api.nvim_set_hl(0, "TelescopeMatching", { bg = "NONE", fg = "#ffffff" })

		vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = grey_2 })
		vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = grey_2 })
		vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { bg = grey_2, fg = grey_2 })
		vim.api.nvim_set_hl(0, "NeoTreeIndentMarker", { bg = "NONE", fg = "#444444" })

		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { bg = "#3f1d1d", fg = "#ff6c6b", bold = true })
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { bg = "#3f3a1d", fg = "#e5c07b", bold = true })
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { bg = "#1d3f3f", fg = "#56b6c2", bold = true })
		vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { bg = "#2d2d3f", fg = "#c678dd", bold = true })

		vim.cmd("highlight! StatusLine guibg=NONE")
	end,
}
