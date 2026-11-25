return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	event = {
		"BufReadPre " .. vim.fn.expand("~") .. "/ObsidianVault/**/*.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/ObsidianVault/**/*.md",
	},

	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "personal",
					path = "~/ObsidianVault/",
				},
			},
			legacy_commands = false,
			frontmatter = { enabled = false },
			ui = {
				enable = false,
			},
		})

		local function set_keymaps(buf)
			local opts = function(desc)
				return { buffer = buf, noremap = true, silent = true, desc = desc }
			end
			vim.keymap.set("n", "<leader>sb", "<cmd>Obsidian backlinks<CR>", opts("Obsidian backlinks"))
			vim.keymap.set("n", "<leader>st", "<cmd>Obsidian tags<CR>", opts("Obsidian tags"))
			vim.keymap.set("n", "<leader>gd", "<cmd>Obsidian follow_link<CR>", opts("Obsidian follow link"))
			vim.keymap.set("n", "<leader>o", "<cmd>Obsidian open<CR>", opts("Obsidian open"))
		end

		local vault_prefix = vim.fs.normalize(vim.fn.expand("~/ObsidianVault")) .. "/"
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) then
				local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
				if vim.startswith(name, vault_prefix) then
					set_keymaps(buf)
				end
			end
		end

		vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
			group = vim.api.nvim_create_augroup("obsidian-keymaps", { clear = true }),
			pattern = vim.fn.expand("~") .. "/ObsidianVault/**/*.md",
			callback = function(ev)
				set_keymaps(ev.buf)
			end,
		})
	end,
}
