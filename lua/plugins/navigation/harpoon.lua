---Configure Harpoon file marks and quick navigation.
local function harpoon_keys()
	local keys = {
		{
			"<leader>h",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Harpoon menu",
		},
		{
			"<leader>a",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Harpoon add file",
		},
	}
	for i = 1, 8 do
		keys[#keys + 1] = {
			"<leader>" .. i,
			function()
				require("harpoon"):list():select(i)
			end,
			desc = "Harpoon file " .. i,
		}
	end
	return keys
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = harpoon_keys(),
	opts = {
		settings = {
			save_on_toggle = true,
		},
	},
}
