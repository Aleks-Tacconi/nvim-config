# Neovim Configuration

## Installation

1. Backup your current configuration (optional):

    ```sh
    mv ~/.config/nvim ~/.config/nvim-backup/
    ```

2. Clone this repository into your `~/.config/nvim` folder:

    ```sh
    git clone https://github.com/Aleks-Tacconi/nvim-config.git ~/.config/nvim
    ```

## Plugins

This configuration uses the [folke/lazy.nvim](https://github.com/folke/lazy.nvim) package manager to install and manage plugins.

| Plugin                                                                                                    | Description                                                                                   | File                                             |
|-----------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|--------------------------------------------------|
| [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)                                         | The colorscheme                                                                               | lua/plugins/appearance/colorscheme.lua           |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                     | Adds git signs to the sidebar + other git integration for example:<br> `:Git blame`           | lua/plugins/appearance/gitsigns.lua              |
| [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)             | Adds indentation guides                                                                       | lua/plugins/appearance/indent-blankline.lua      |
| [brenoprata10/nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors)               | Highlights color codes with their corresponding colors                                        | lua/plugins/appearance/nvim-highlight-colors.lua |
| [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Plugin to improve viewing Markdown files in Neovim                                            | lua/plugins/appearance/render-markdown.lua       |
| [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)                                   | Highlight and search for todo comments like TODO, HACK, BUG in your code base                 | lua/plugins/appearance/todo-comments.lua         |
| [xiyaowong/transparent.nvim](https://github.com/xiyaowong/transparent.nvim)                               | Remove all background colors to make Neovim transparent                                       | lua/plugins/appearance/transparent.lua           |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                     | Improved syntax-highlighting                                                                  | lua/plugins/appearance/treesitter.lua            |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)                                         | Formatter for Neovim                                                                          | lua/plugins/lsp-config/conform.lua               |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim)                                               | Speeds up the Lua Language Server setup by lazily loading only the required Lua modules       | lua/plugins/lsp-config/lazy-dev.lua              |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                                                   | Completion engine for Neovim                                                                  | lua/plugins/lsp-config/nvim-cmp.lua              |
| [mfussenegger/nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)                                     | Provides LSP support for java in Neovim                                                       | lua/plugins/lsp-config/nvim-jdtls.lua            |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)                                       | An asynchronous linter plugin for Neovim                                                      | lua/plugins/lsp-config/nvim-lint.lua             |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                         | Helps configure and manage LSP servers in Neovim                                              | lua/plugins/lsp-config/nvim-lspconfig.lua        |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs)                                         | Automatically closes brackets                                                                 | lua/plugins/misc/autopairs.lua                   |
| [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)                                       | Uses treesitter to autoclose and autorename html tag                                          | lua/plugins/misc/autotags.lua                    |
| [LunarVim/bigfile.nvim](https://github.com/LunarVim/bigfile.nvim)                                         | Disables some features when editing big files for improved performance                        | lua/plugins/misc/bigfile.lua                     |
| [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)                                         | Provides chatGPT integration + selection menu for different commands using telescope          | lua/plugins/misc/chatgpt.lua                     |
| [toppair/peek.nvim](https://github.com/toppair/peek.nvim)                                                 | A markdown preview plugin                                                                     | lua/plugins/misc/peek.lua                        |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim)                                               | Tool for improving diagnostic viewing experience                                              | lua/plugins/misc/trouble.lua                     |
| [yioneko/nvim-yati](https://github.com/yioneko/nvim-yati)                                                 | Improved indentation using tresitter                                                          | lua/plugins/misc/yati.lua                        |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                                     | Tabbar (configured to show buffers selected via harpoon)                                      | lua/plugins/navigation/bufferline.lua            |
| [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon)                                           | Tool for marking and navigating buffers                                                       | lua/plugins/navigation/harpoon.lua               |
| [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)                             | Directory Tree for Neovim                                                                     | lua/plugins/navigation/neo-tree.lua              |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)                         | Fuzzy finder for Neovim                                                                       | lua/plugins/navigation/telescope.lua             |

## Plugin-Specific Key Binds

`<leader>` refers to space. This is set in lua/config/options.lua in the globals table.<br>
All the following plugin specific key binds are set in the respective file for the plugin.

| Plugin                                                                                                    | Key Bind(s)                                                                                                              | 
|-----------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| [MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | `<leader>m` - Toggle render markdown                                                                                     |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)                                         | `<leader>ff` - Format file                                                                                               |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)                                                   | `Ctrl+y` - Accept suggestion<br>`Ctrl+j` - Move selection down<br>`Ctrl+k` - Move selection up                           |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                         | `gd` - Go to definition<br>`gr` - Go to references<br>`gI` - Go to implementation<br>`<leader>D` - Go to type definition | 
| [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)                                         | `<leader>o` - Open chatGPT command menu                                                                                  |
| [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon)                                           | `<leader>a` - Add buffer to harpoon<br>`<leader>h` - Open harpoon menu<br>`<leader>[number]`Go to buffer indexed number  |
| [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)                             | `<leader>d` - Toggle directory tree                                                                                      |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)                         | `<leader>sf` - Search files<br>`<leader>sg` - Live grep project<br>`<leader>sd` - Search diagnostics                     |
