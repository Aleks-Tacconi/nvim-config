---Notebook plugin specs: Molten (kernel), image.nvim, Otter.
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    ft = { "markdown" },
    cmd = {
      "NewNotebook",
      "NotebookLoadOutputs",
      "NotebookSaveOutputs",
      "NotebookClearOutputs",
      "MoltenClearExport",
      "NotebookHelp",
    },
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      local io_group = vim.api.nvim_create_augroup("notebook_ipynb_io", { clear = true })
      vim.api.nvim_create_autocmd("BufReadCmd", {
        group = io_group,
        pattern = "*.ipynb",
        callback = function(ev)
          require("utils.notebook").read_buf(ev.buf, ev.match)
        end,
      })
      vim.api.nvim_create_autocmd({ "BufWriteCmd", "FileWriteCmd" }, {
        group = io_group,
        pattern = "*.ipynb",
        callback = function(ev)
          require("utils.notebook").write_buf(ev.buf, ev.match)
        end,
      })

      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_image_location = "both"
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_max_lines = 12
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_output_win_border = "rounded"
      vim.g.molten_output_win_hide_on_leave = true
      vim.g.molten_output_win_style = "minimal"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_output_win_max_width = 100
      vim.g.molten_enter_output_behavior = "open_and_enter"
      vim.g.molten_wrap_output = true
    end,
    config = function()
      require("utils.notebook").setup()
    end,
  },

  {
    "3rd/image.nvim",
    lazy = true,
    opts = {
      backend = "kitty",
      tmux_show_only_in_active_window = true,
      max_width = 100,
      max_height = 25,
      max_height_window_percentage = 50,
      max_width_window_percentage = 90,
      window_overlap_clear_enabled = true,
    },
  },

  {
    "jmbuhr/otter.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      lsp = {
        diagnostic_update_events = { "BufWritePost", "InsertLeave" },
      },
    },
  },
}
