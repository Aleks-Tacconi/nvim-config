---Register user command aliases.

local commands = { "w", "q", "wq", "wqa", "wa" }

---Return uppercase variants for an Ex command.
---@param command string
---@return string[]
local function command_variants(command)
	local variants = { [command:upper()] = true }

	for i = 1, #command do
		variants[command:sub(1, i):upper() .. command:sub(i + 1)] = true
	end

	return vim.tbl_keys(variants)
end

for _, command in ipairs(commands) do
	for _, variant in ipairs(command_variants(command)) do
		vim.api.nvim_create_user_command(variant, command, {})
	end
end
