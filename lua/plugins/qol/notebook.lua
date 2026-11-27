---Notebook plugin specs: Molten (kernel), image.nvim, Otter.

---Return the number of virtual lines Molten placed on `row` in `buf`.
local function molten_virt_line_count(buf, row)
  local ns = vim.api.nvim_get_namespaces()["molten-extmarks"]
  if not ns or not buf or not row or not vim.api.nvim_buf_is_valid(buf) then
    return 0
  end
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, { details = true })
  local count = 0
  for _, mark in ipairs(marks) do
    if mark[4] and mark[4].virt_lines then
      count = count + #mark[4].virt_lines
    end
  end
  return count
end

---Return true when Neovim is outside tmux or inside the currently active tmux window and pane.
local function is_tmux_pane_visible()
  if not vim.env.TMUX or not vim.env.TMUX_PANE then
    return true
  end
  local res = vim.system(
    { "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{window_active} #{pane_active}" },
    { text = true }
  ):wait()
  return res.code == 0 and vim.trim(res.stdout or "") == "1 1"
end

---Wrap `image.from_file` so Molten virtual plots sit below virtual text without double-padding.
local function wrap_molten_images(image, utils, state)
  local in_molten_virt = false
  local orig_reserved = utils.virtual_padding.get_reserved_lines
  utils.virtual_padding.get_reserved_lines = function(height, render_offset_top, overlap)
    return orig_reserved(height, in_molten_virt and 0 or render_offset_top, overlap)
  end

  local orig_from_file = image.from_file
  image.from_file = function(path, img_opts)
    local img = orig_from_file(path, img_opts)
    if img and not img._notebook_wrapped then
      img._notebook_wrapped = true
      local orig_render = img.render
      img.render = function(self, geometry)
        if not state.visible then
          state.hidden[self.id] = self
          return
        end
        if vim.startswith(self.id or "", "virt-") then
          self.render_offset_top = molten_virt_line_count(self.buffer, self.geometry.y)
          in_molten_virt = true
          local ok, err = pcall(orig_render, self, geometry)
          in_molten_virt = false
          if not ok then
            error(err)
          end
          return
        end
        return orig_render(self, geometry)
      end
    end
    return img
  end
end

---Clear Kitty images when leaving this tmux window or pane and restore them on return.
local function setup_tmux_visibility(image, state)
  if not vim.env.TMUX or not vim.env.TMUX_PANE then
    return
  end
  local group = vim.api.nvim_create_augroup("notebook_tmux_images", { clear = true })
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      if not is_tmux_pane_visible() then
        state.visible = false
        for _, img in ipairs(image.get_images()) do
          if img.is_rendered then
            state.hidden[img.id] = img
            img:clear(true)
          end
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      if not state.visible and is_tmux_pane_visible() then
        state.visible = true
        local to_restore = state.hidden
        state.hidden = {}
        vim.schedule(function()
          for _, img in pairs(to_restore) do
            img:render()
          end
        end)
      end
    end,
  })
end

---Configure `image.nvim` with Molten virtual-text alignment and tmux pane isolation.
local function setup_notebook_images(opts)
  local image = require("image")
  local utils = require("image.utils")
  local state = { visible = true, hidden = {} }

  utils.tmux.get_pane_tty = function()
    return nil
  end
  image.setup(opts)
  wrap_molten_images(image, utils, state)
  setup_tmux_visibility(image, state)
end

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
      vim.g.molten_image_location = "virt"
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
      tmux_show_only_in_active_window = false,
      max_width = 100,
      max_height = 25,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "" },
    },
    config = function(_, opts)
      setup_notebook_images(opts)
    end,
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
