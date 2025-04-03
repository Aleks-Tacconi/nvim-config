local options = {
	number = true, -- Show line numbers
	relativenumber = true, -- Enable relative line numbers
	numberwidth = 4, -- Set line number column width
	signcolumn = "yes", -- Always show the sign column
	wrap = false, -- Disable line wrapping
	cursorline = true, -- Highlight the current line
	scrolloff = 8, -- Keep at least 8 lines above/below the cursor
	sidescrolloff = 8, -- Keep at least 8 columns left/right of the cursor
	termguicolors = true, -- Enable GUI colors in terminal
	expandtab = true, -- Convert tabs to spaces
	shiftwidth = 4, -- Number of spaces per indentation level
	tabstop = 4, -- Number of spaces per tab
	smartindent = true, -- Enable smart indentation
	breakindent = true, -- Maintain indentation when wrapping lines
	hlsearch = true, -- Highlight search matches
	ignorecase = true, -- Ignore case in searches
	smartcase = true, -- Case-sensitive if uppercase letters are used
	mouse = "a", -- Enable mouse support
	clipboard = "unnamedplus", -- Use system clipboard
	laststatus = 3, -- Enable global status bar
	showmode = false, -- Hide mode display (e.g., -- INSERT --)
	cmdheight = 2, -- Increase command-line height for messages
	completeopt = { "menuone", "noselect" }, -- Completion options
	pumheight = 10, -- Popup menu height
	timeoutlen = 1000, -- Timeout for mapped sequences (ms)
	updatetime = 300, -- Faster update time for UI events (ms)
	undofile = true, -- Enable persistent undo
	swapfile = false, -- Disable swap file creation
	backup = false, -- Disable backup file creation
	writebackup = false, -- Prevent editing conflicts
	splitbelow = true, -- Horizontal splits appear below
	splitright = true, -- Vertical splits appear to the right
	ruler = false, -- Disable ruler
	showcmd = false, -- Disable cmd
	spelllang = "en_us", -- Set spelling language
	spell = true, -- enable spell check
}

local globals = {
	loaded_netrw = 1, -- Disable netrw
	loaded_netrwPlugin = 1, -- Disable netrw
	loaded_perl_provider = 0, -- Disable perl provider
	loaded_ruby_provider = 0, -- Disable ruby provider
	mapleader = " ", -- Set leader to space
	maplocalleader = " ", -- Set leader to space
	have_nerd_font = true, -- Tells nvim that nerd font is installed
}

-- Treat hyphenated words as a single word in motions
vim.opt.iskeyword:append("-")

local function assign(dict, config)
	for k, v in pairs(config) do
		dict[k] = v
	end
end

assign(vim.opt, options)
assign(vim.g, globals)

-- Env
vim.env.PYTHONPATH = vim.fn.getcwd()
