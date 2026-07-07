local function set_molten_virtual_output(enabled)
  vim.g.molten_virt_text_output = enabled
  if vim.fn.exists("*MoltenUpdateOption") == 1 then
    pcall(vim.fn.MoltenUpdateOption, "virt_text_output", enabled)
  end
end

local function enable_molten_virtual_output()
  set_molten_virtual_output(true)
end

return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      local function set_output_window_size()
        vim.g.molten_output_win_max_height = math.floor(vim.o.lines * 0.8)
        vim.g.molten_output_win_max_width = math.floor(vim.o.columns * 0.8)
      end

      set_output_window_size()
      vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
          set_output_window_size()
          if vim.fn.exists("*MoltenUpdateOption") == 1 then
            vim.fn.MoltenUpdateOption("output_win_max_height", vim.g.molten_output_win_max_height)
            vim.fn.MoltenUpdateOption("output_win_max_width", vim.g.molten_output_win_max_width)
          end
        end,
      })

      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_show_more = true
      vim.g.molten_output_win_border = "rounded"
      vim.g.molten_output_win_hide_on_leave = true
      vim.g.molten_output_win_style = "minimal"
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
    end,
    config = function()
      local function center_molten_output()
        local width = math.floor(vim.o.columns * 0.8)
        local height = math.floor(vim.o.lines * 0.8)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        if vim.bo.filetype ~= "molten_output" then
          return
        end

        vim.api.nvim_win_set_config(0, {
          relative = "editor",
          row = row,
          col = col,
          width = width,
          height = height,
          border = "rounded",
          style = "minimal",
          focusable = true,
        })
      end

      local function clear_molten_virtual_output()
        local namespace = vim.api.nvim_get_namespaces()["molten-extmarks"]
        if not namespace then
          return
        end

        local extmarks = vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, { details = true })
        for _, extmark in ipairs(extmarks) do
          local id = extmark[1]
          local details = extmark[4] or {}
          if details.virt_lines then
            pcall(vim.api.nvim_buf_del_extmark, 0, namespace, id)
          end
        end
      end

      local function hide_molten_output()
        set_molten_virtual_output(false)
        pcall(vim.cmd, "MoltenHideOutput")
        clear_molten_virtual_output()
      end

      local function enter_molten_output()
        vim.cmd("noautocmd MoltenEnterOutput")
        vim.schedule(center_molten_output)
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "molten_output",
        callback = function(event)
          vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, desc = "close output", silent = true })
        end,
      })

      vim.keymap.set("n", "<localleader>e", function()
        enable_molten_virtual_output()
        vim.cmd("MoltenEvaluateOperator")
      end, { desc = "evaluate operator", silent = true })
      vim.keymap.set("v", "<localleader>r", function()
        enable_molten_virtual_output()
        vim.cmd("'<,'>MoltenEvaluateVisual")
        vim.cmd("normal! gv")
      end, { desc = "execute visual selection", silent = true })
      vim.keymap.set("n", "<localleader>rr", function()
        enable_molten_virtual_output()
        vim.cmd("MoltenReevaluateCell")
      end, { desc = "re-eval cell", silent = true })
      vim.keymap.set("n", "<localleader>os", enter_molten_output, { desc = "open output window", silent = true })
      vim.keymap.set("n", "<localleader>oh", hide_molten_output, { desc = "hide output", silent = true })
      vim.keymap.set("n", "<leader>oh", hide_molten_output, { desc = "hide output", silent = true })
    end,
  },

  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
    },
  },

  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },

  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("quarto").setup({
        lspFeatures = {
          languages = { "python" },
          chunks = "all",
          diagnostics = { enabled = true },
          completion = { enabled = true },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      })

      local runner = require("quarto.runner")
      vim.keymap.set("n", "<localleader>rc", function()
        enable_molten_virtual_output()
        runner.run_cell()
      end, { desc = "run cell", silent = true })
      vim.keymap.set("n", "<localleader>ra", function()
        enable_molten_virtual_output()
        runner.run_above()
      end, { desc = "run above", silent = true })
      vim.keymap.set("n", "<localleader>rA", function()
        enable_molten_virtual_output()
        runner.run_all()
      end, { desc = "run all", silent = true })
      vim.keymap.set("v", "<localleader>r", function()
        enable_molten_virtual_output()
        runner.run_range()
      end, { desc = "run range", silent = true })
    end,
  },
}
