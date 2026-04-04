# Neovim Configuration

![./assets/1.png](./assets/1.png)

## Installation

1. Backup your current configuration (optional):

    ```sh
    mv ~/.config/nvim ~/.config/nvim-backup/
    ```

2. Clone this repository into your `~/.config/nvim` folder:

    ```sh
    git clone https://github.com/Aleks-Tacconi/nvim-config.git ~/.config/nvim
    ```

3. Sync plugins and Treesitter parsers after installing or after a Neovim upgrade:

    ```sh
    nvim --headless "+Lazy! sync" "+TSUpdateSync" "+qa"
    ```
