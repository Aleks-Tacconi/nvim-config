local servers = {}
local tools = {}

local files = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/lsp/config/languages/*.lua", true, true)
for _, file in ipairs(files) do
	if not file:match("init.lua$") then
		local lang_config = dofile(file)
		vim.list_extend(tools, lang_config.tools)
		for server, config in pairs(lang_config.servers) do
			servers[server] = config
		end
	end
end

return {
	servers = servers,
	tools = tools,
}
