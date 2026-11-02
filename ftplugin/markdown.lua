---Enable Quarto and buffer-local notebook cell textobjects.
require("quarto").activate()

local mappings = {
	{ { "n", "x", "o" }, "]b", "move", "goto_next_start", "@code_cell.inner", "Next code block" },
	{ { "n", "x", "o" }, "[b", "move", "goto_previous_start", "@code_cell.inner", "Previous code block" },
	{ { "x", "o" }, "ib", "select", "select_textobject", "@code_cell.inner", "Inside code block" },
	{ { "x", "o" }, "ab", "select", "select_textobject", "@code_cell.outer", "Around code block" },
	{ "n", "<leader>sbl", "swap", "swap_next", "@code_cell.outer", "Swap with next code block" },
	{ "n", "<leader>sbh", "swap", "swap_previous", "@code_cell.outer", "Swap with previous code block" },
}

for _, mapping in ipairs(mappings) do
	vim.keymap.set(mapping[1], mapping[2], function()
		require("nvim-treesitter-textobjects." .. mapping[3])[mapping[4]](mapping[5], "textobjects")
	end, { buf = 0, silent = true, desc = mapping[6] })
end
