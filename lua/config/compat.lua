--- Compatibility shims for newer Neovim releases.

if vim.tbl_flatten and vim.iter then
	--- Flatten nested list-like tables without using the deprecated builtin.
	---@param values table
	---@return table
	function vim.tbl_flatten(values)
		return vim.iter(values):flatten(math.huge):totable()
	end
end
