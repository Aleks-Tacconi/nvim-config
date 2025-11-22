local function found(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

local function get_ft()
	local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/lsp/config/languages/*.lua", true, true)
	local ft_list = {}

	for _, file in ipairs(files) do
		local lang_config = dofile(file)
		for _, ft in ipairs(lang_config.linters_ft) do
			vim.list_extend(ft_list, { ft })
		end
	end

	return ft_list
end

return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local ft_list = get_ft()

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				local ft = vim.bo.filetype

				if found(ft_list, ft) then
					require("lint").try_lint()
				end
			end,
		})
	end,
}
