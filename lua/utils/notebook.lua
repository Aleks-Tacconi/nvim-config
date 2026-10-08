---Notebook utilities for Molten, Jupytext, and Quarto integration.
local M = {}

local OUTPUT_WIN_RATIO = 0.8
M.default_notebook_json = vim.json.encode({
  cells = {
    {
      id = "cell-1",
      cell_type = "code",
      execution_count = vim.NIL,
      metadata = vim.empty_dict(),
      outputs = {},
      source = {},
    },
  },
  metadata = {
    kernelspec = { display_name = "Python 3", language = "python", name = "python3" },
    language_info = { name = "python", version = "3" },
  },
  nbformat = 4,
  nbformat_minor = 5,
})

--------------------------------------------------------------------------------
-- SETUP & INITIALIZATION
--------------------------------------------------------------------------------

---Guards vim.fn.screenpos against Vim:E966 when queried line exceeds buffer length.
local function patch_screenpos()
  if vim.g._screenpos_patched then return end
  vim.g._screenpos_patched = true

  local orig = vim.fn.screenpos
  vim.fn.screenpos = function(win, lnum, col)
    local ok, res = pcall(orig, win, lnum, col)
    if ok then return res end

    local buf = vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win)
    if buf and vim.api.nvim_buf_is_valid(buf) then
      local count = vim.api.nvim_buf_line_count(buf)
      if lnum > count then
        local pad = {}
        for _ = 1, (lnum - count + 12) do
          table.insert(pad, "")
        end
        pcall(vim.api.nvim_buf_set_lines, buf, count, count, false, pad)
        local ok2, res2 = pcall(orig, win, lnum, col)
        if ok2 then return res2 end
      end
    end

    return { row = 0, col = 0, curscol = 0, endcol = 0 }
  end
end

local loaded_molten_images = {}

---Patches Molten's image_api to keep images rendered in the persistent right pane
---even when the cursor moves out of the code block.
local function patch_molten_image_api()
  local ok, load_image = pcall(require, "load_image_nvim")
  if not ok or not load_image.image_api then return end
  local api = load_image.image_api
  if api._patched_right_pane then return end
  api._patched_right_pane = true

  local function get_right_pane_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local r_ok, is_right = pcall(vim.api.nvim_win_get_var, win, "is_molten_right_pane")
      if r_ok and is_right and vim.api.nvim_win_is_valid(win) then
        return win
      end
    end
    return nil
  end

  local orig_from_file = api.from_file
  api.from_file = function(path, opts)
    opts = opts or {}
    local right_win = get_right_pane_win()
    if right_win then
      opts.window = right_win
    end
    local res = orig_from_file(path, opts)
    loaded_molten_images[path] = {
      buffer = opts.buffer,
      window = right_win,
    }
    return res
  end

  local orig_render = api.render
  api.render = function(identifier, geometry)
    local right_win = get_right_pane_win()
    local ok_img, image_mod = pcall(require, "image")
    if ok_img and image_mod.get_images then
      for _, img in ipairs(image_mod.get_images()) do
        if (img.path == identifier or img.id == identifier) and right_win then
          img.window = right_win
        end
      end
    end

    orig_render(identifier, geometry)

    if ok_img and image_mod.get_images then
      for _, img in ipairs(image_mod.get_images()) do
        if (img.path == identifier or img.id == identifier) and right_win then
          img.window = right_win
        end
      end
    end
  end

  local orig_clear = api.clear
  api.clear = function(identifier)
    local right_win = get_right_pane_win()
    if right_win and vim.api.nvim_win_is_valid(right_win) then
      local right_buf = vim.api.nvim_win_get_buf(right_win)
      local entry = loaded_molten_images[identifier]
      if entry and entry.buffer == right_buf then
        -- Output buffer is still displayed in the right pane; keep image rendered.
        return
      end

      local ok_img, image_mod = pcall(require, "image")
      if ok_img and image_mod.get_images then
        for _, img in ipairs(image_mod.get_images()) do
          if (img.path == identifier or img.id == identifier) and img.buffer == right_buf then
            return
          end
        end
      end
    end

    orig_clear(identifier)
  end
end

---Initializes Molten plugin variables before it loads
function M.init()
  patch_screenpos()
  patch_molten_image_api()
  M.set_output_window_size()
  vim.api.nvim_create_autocmd("VimResized", { callback = M.set_output_window_size })

  vim.g.molten_auto_open_output = true -- Auto-selects cells and updates output in the right pane
  vim.g.molten_image_provider = "image.nvim"
  vim.g.molten_image_location = "float" -- Render images only in the right pane, not inline
  vim.g.molten_output_show_more = false
  vim.g.molten_output_show_exec_time = true
  vim.g.molten_output_win_border = "none" -- Remove border entirely to prevent artifacts
  vim.g.molten_output_win_hide_on_leave = false
  vim.g.molten_output_win_style = "minimal"
  vim.g.molten_wrap_output = true
  vim.g.molten_tick_rate = 150 -- Fast polling for responsive cell output updates
  
  -- Virtual Text Settings (Execution Status)
  vim.g.molten_virt_text_output = true -- Enable inline virtual text for status
  vim.g.molten_virt_text_max_lines = 2 -- Limit inline text to 2 lines (Status line + "More Lines" indicator). Keeps code clean!
  vim.g.molten_virt_lines_off_by_1 = true
end

---Hides any floating window displaying a molten output buffer so output stays in the right pane.
---@param buf? integer
local function hide_molten_floats(buf)
  local wins = buf and vim.fn.win_findbuf(buf) or vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative and cfg.relative ~= "" then
        pcall(vim.api.nvim_win_set_config, win, { hide = true })
      end
    end
  end
end

local cell_margin_ns = vim.api.nvim_create_namespace("notebook_active_cell_margin")

---Finds the fenced code block enclosing the cursor, or falls back to the first cell if none is active yet.
---@param buf integer
---@return integer? start_row, integer? end_row
local function get_active_cell_range(buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { row, col } })
  if ok and node then
    local curr = node
    while curr do
      if curr:type() == "fenced_code_block" then
        local s, _, e, _ = curr:range()
        return s, e
      end
      curr = curr:parent()
    end
  end

  -- Fall back to first code cell if the buffer has no selection yet
  if not vim.b[buf].active_cell_range then
    local p_ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
    if p_ok and parser then
      local tree = parser:parse()[1]
      local query = vim.treesitter.query.parse("markdown", "((fenced_code_block) @cell)")
      for _, c_node in query:iter_captures(tree:root(), buf) do
        local s, _, e, _ = c_node:range()
        return s, e
      end
    end
  end

  return nil, nil
end

local empty_output_buf = nil

---Returns or creates a reusable empty scratch buffer for the right pane.
---@return integer
local function get_empty_output_buf()
  if not empty_output_buf or not vim.api.nvim_buf_is_valid(empty_output_buf) then
    empty_output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[empty_output_buf].buftype = "nofile"
    vim.bo[empty_output_buf].bufhidden = "hide"
    vim.bo[empty_output_buf].swapfile = false
    vim.api.nvim_buf_set_lines(empty_output_buf, 0, -1, false, {})
  end
  return empty_output_buf
end

---Clears the right pane to show an empty buffer if open.
function M.clear_right_pane()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, is_right = pcall(vim.api.nvim_win_get_var, win, "is_molten_right_pane")
    if ok and is_right then
      local empty_buf = get_empty_output_buf()
      if vim.api.nvim_win_get_buf(win) ~= empty_buf then
        vim.api.nvim_win_set_buf(win, empty_buf)
      end
      pcall(function()
        local ok_img, image_mod = pcall(require, "image")
        if ok_img and image_mod.get_images then
          for _, img in ipairs(image_mod.get_images()) do
            if img.window == win then
              img:clear()
            end
          end
        end
      end)
      return
    end
  end
end

---Returns true if the cell range has an associated molten output extmark.
---@param buf integer
---@param start_row integer
---@param end_row integer
---@return boolean
local function cell_has_molten_output(buf, start_row, end_row)
  local ns = vim.api.nvim_get_namespaces()["molten-extmarks"]
  if not ns then return false end
  local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { start_row, 0 }, { end_row, 0 }, { details = true })
  return #marks > 0
end

---Updates the active code cell margin highlight in the sign column.
---@param buf integer
local function update_active_cell_margin(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end

  local start_row, end_row = get_active_cell_range(buf)
  if not (start_row and end_row) then
    return
  end

  local cur_range = vim.b[buf].active_cell_range
  if cur_range and cur_range[1] == start_row and cur_range[2] == end_row then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, cell_margin_ns, 0, -1)
  vim.b[buf].active_cell_range = { start_row, end_row }
  for r = start_row, end_row - 1 do
    vim.api.nvim_buf_set_extmark(buf, cell_margin_ns, r, 0, {
      sign_text = "▎",
      sign_hl_group = "NotebookActiveCellMargin",
      priority = 20,
    })
  end

  if cell_has_molten_output(buf, start_row, end_row) then
    pcall(vim.cmd, "MoltenShowOutput")
  else
    M.clear_right_pane()
  end
end

---Sets up autocmds and user commands after Molten loads
function M.setup()
  local group = vim.api.nvim_create_augroup("notebook_setup", { clear = true })
  vim.api.nvim_set_hl(0, "NotebookActiveCellMargin", { fg = "#89b4fa", default = true })

  patch_molten_image_api()

  if vim.fn.exists("*MoltenUpdateOption") == 1 then
    pcall(vim.fn.MoltenUpdateOption, "image_location", "float")
  end

  -- Sync newly created or reopened Molten buffers to the right pane IMMEDIATELY.
  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
    group = group,
    pattern = "*",
    callback = function(event)
      if vim.bo[event.buf].filetype == "molten_output" then
        M.set_output_keymaps(event.buf)
        M.open_in_right_pane(event.buf)
        hide_molten_floats(event.buf)
      end
    end,
  })

  -- Markdown / Notebook Initialization
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(event)
      if M.is_notebook(vim.api.nvim_buf_get_name(event.buf)) then
        M.set_buffer_keymaps(event.buf)
        -- Inject Python LSP diagnostics into markdown notebook code blocks
        local ok, otter = pcall(require, "otter")
        if ok then
          otter.activate({ "python" }, true, true, nil)
        end
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          group = group,
          buffer = event.buf,
          callback = function()
            update_active_cell_margin(event.buf)
          end,
        })
        update_active_cell_margin(event.buf)
      end
    end,
  })

  -- Lifecycle Management
  vim.api.nvim_create_autocmd("BufNewFile", {
    group = group,
    pattern = "*.ipynb",
    callback = function(args)
      if M.write_template(args.file) then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            vim.api.nvim_buf_call(args.buf, function() vim.cmd.edit({ bang = true }) end)
          end
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWritePost", "BufUnload" }, {
    group = group,
    pattern = "*.ipynb",
    callback = function(args) M.remove_md_residue(args.file) end,
  })

  vim.api.nvim_create_autocmd("FileChangedShell", {
    group = group,
    pattern = "*.ipynb",
    callback = function() vim.v.fcs_choice = "reload" end,
  })

  -- User Commands
  vim.api.nvim_create_user_command("NewNotebook", function(opts)
    M.create_new_notebook(opts.args)
  end, { nargs = 1, complete = "file", desc = "Create and open a new Jupyter notebook" })

  vim.api.nvim_create_user_command("NotebookToPdf", function(opts)
    M.export_to_pdf(opts.args ~= "" and opts.args or nil)
  end, {
    nargs = "?",
    complete = function() return { "pdf", "typst", "webpdf" } end,
    desc = "Export current notebook to PDF (optional arg: pdf, typst, webpdf)",
  })

  vim.api.nvim_create_user_command("NotebookClearOutputs", M.clear_outputs, {
    desc = "Clear all outputs from the current notebook file",
  })

  vim.api.nvim_create_user_command("NotebookHelp", require("utils.notebook_help").show, {
    desc = "Show notebook shortcuts and commands cheatsheet",
  })
end


--------------------------------------------------------------------------------
-- WINDOW & UI MANAGEMENT
--------------------------------------------------------------------------------

---Opens the molten buffer in a persistent right pane
---@param buf integer
---@return boolean
function M.open_in_right_pane(buf)
  local right_pane_win = nil

  -- Locate the relevant windows
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, is_right = pcall(vim.api.nvim_win_get_var, win, "is_molten_right_pane")
    if ok and is_right then
      right_pane_win = win
    end
  end

  -- Create the right pane if it doesn't exist
  if not right_pane_win or not vim.api.nvim_win_is_valid(right_pane_win) then
    local original_win = vim.api.nvim_get_current_win()
    vim.cmd("botright vsplit")
    right_pane_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_var(right_pane_win, "is_molten_right_pane", true)
    vim.api.nvim_win_set_width(right_pane_win, math.floor(vim.o.columns * 0.3))
    vim.api.nvim_set_current_win(original_win)
  end

  -- Display the molten buffer in our right pane
  if vim.api.nvim_win_get_buf(right_pane_win) ~= buf then
    vim.api.nvim_win_set_buf(right_pane_win, buf)
    vim.api.nvim_set_option_value("wrap", true, { win = right_pane_win })
    vim.api.nvim_set_option_value("number", false, { win = right_pane_win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = right_pane_win })
    vim.api.nvim_set_option_value("signcolumn", "yes:1", { win = right_pane_win }) -- Adds clean left padding
    vim.api.nvim_set_option_value("cursorline", true, { win = right_pane_win })
    vim.api.nvim_set_option_value("statusline", " %#String# 󰌠 Jupyter Output ", { win = right_pane_win })
    vim.api.nvim_set_option_value("winhighlight", "StatusLine:Title,StatusLineNC:Comment", { win = right_pane_win })
    pcall(vim.api.nvim_set_option_value, "syntax", "python", { buf = buf }) -- Highlight arrays/dicts nicely
  end

  return true
end

---Focuses the persistent right pane if it exists, showing output for the active cell.
function M.enter_output()
  pcall(vim.cmd, "MoltenShowOutput")
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, is_right = pcall(vim.api.nvim_win_get_var, win, "is_molten_right_pane")
    if ok and is_right then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.notify("No active Jupyter output pane found.", vim.log.levels.WARN)
end

---Hides all Molten output: float window and inline virtual text.
function M.hide_output()
  M.set_virtual_output(false)
  pcall(vim.cmd, "MoltenHideOutput")
  M.clear_virtual_output()
end

---Caps Molten output windows to 1x1 to prevent popup flashes over the editor.
function M.set_output_window_size()
  vim.g.molten_output_win_max_height = 1
  vim.g.molten_output_win_max_width = 1
  if vim.fn.exists("*MoltenUpdateOption") == 1 then
    vim.fn.MoltenUpdateOption("output_win_max_height", 1)
    vim.fn.MoltenUpdateOption("output_win_max_width", 1)
  end
end

---Toggles Molten virtual text output option.
---@param enabled boolean
function M.set_virtual_output(enabled)
  vim.g.molten_virt_text_output = enabled
  if vim.fn.exists("*MoltenUpdateOption") == 1 then
    pcall(vim.fn.MoltenUpdateOption, "virt_text_output", enabled)
  end
end

---Clears Molten virtual text extmarks in the current buffer.
function M.clear_virtual_output()
  local namespace = vim.api.nvim_get_namespaces()["molten-extmarks"]
  if not namespace then return end

  local extmarks = vim.api.nvim_buf_get_extmarks(0, namespace, 0, -1, { details = true })
  for _, extmark in ipairs(extmarks) do
    if (extmark[4] or {}).virt_lines then
      pcall(vim.api.nvim_buf_del_extmark, 0, namespace, extmark[1])
    end
  end
end


--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------

---Maps q and <Esc> in a Molten output buffer to close the right pane.
---@param buf integer
function M.set_output_keymaps(buf)
  for _, lhs in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", lhs, function()
      local ok, is_right = pcall(vim.api.nvim_win_get_var, 0, "is_molten_right_pane")
      if ok and is_right then
        vim.cmd("close")
      else
        vim.cmd("wincmd p")
        pcall(vim.cmd, "MoltenHideOutput")
      end
    end, { buffer = buf, silent = true, nowait = true })
  end
end

---Runs a quarto runner function and ensures Molten output is shown in the right pane.
---@param name string quarto.runner function name
local function run(name)
  return function()
    require("quarto.runner")[name]()
    pcall(vim.cmd, "MoltenShowOutput")
    vim.schedule(function()
      pcall(vim.cmd, "MoltenShowOutput")
    end)
  end
end

---Sets notebook keymaps local to a notebook buffer.
---@param buf integer
function M.set_buffer_keymaps(buf)
  local maps = {
    { "n", "<localleader>rc", run("run_cell"), "run cell" },
    { "n", "<localleader>ra", run("run_above"), "run above" },
    { "n", "<localleader>rA", run("run_all"), "run all" },
    { "v", "<localleader>r", run("run_range"), "run range" },
    { "n", "<localleader>mi", function()
      local ml_kernel = vim.fn.expand("~/.local/share/jupyter/kernels/machine-learning")
      if vim.fn.isdirectory(ml_kernel) == 1 then
        vim.cmd("MoltenInit machine-learning")
      else
        vim.cmd("MoltenInit")
      end
    end, "initialize molten kernel" },
    { "n", "<localleader>os", M.enter_output, "enter output window" },
    { "n", "<localleader>oh", M.hide_output, "hide output" },
    { "n", "<localleader>ox", "<cmd>MoltenExportOutput!<CR>", "export output to notebook" },
    { "n", "<localleader>op", function() M.export_to_pdf() end, "export notebook to pdf" },
  }
  for _, m in ipairs(maps) do
    vim.keymap.set(m[1], m[2], m[3], { buffer = buf, desc = m[4], silent = true })
  end
end


--------------------------------------------------------------------------------
-- FILE UTILITIES
--------------------------------------------------------------------------------

---Returns true if the path points to a Jupyter notebook.
---@param path string
function M.is_notebook(path)
  return path:match("%.ipynb$") ~= nil
end

---Deletes intermediate markdown file generated by jupytext for an ipynb buffer.
---@param filepath string
function M.remove_md_residue(filepath)
  local md_file = vim.fn.fnamemodify(filepath, ":r") .. ".md"
  if vim.fn.filereadable(md_file) == 1 then
    vim.fn.delete(md_file)
  end
end

---Writes the blank notebook template to path. Returns true on success.
---@param path string
---@return boolean
function M.write_template(path)
  local file = io.open(path, "w")
  if not file then
    vim.notify("Could not create notebook: " .. path, vim.log.levels.ERROR)
    return false
  end
  file:write(M.default_notebook_json)
  file:close()
  return true
end

---Creates a new Jupyter notebook file and opens it.
---@param filename string
function M.create_new_notebook(filename)
  local path = M.is_notebook(filename) and filename or (filename .. ".ipynb")
  if vim.fn.filereadable(path) == 1 then
    vim.notify("Notebook already exists, opening: " .. path, vim.log.levels.WARN)
  elseif not M.write_template(path) then
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
end


--------------------------------------------------------------------------------
-- EXPORT & KERNEL UTILITIES
--------------------------------------------------------------------------------

---Returns the current buffer path if it is a saved notebook, else nil.
---@return string?
local function current_notebook()
  local filepath = vim.api.nvim_buf_get_name(0)
  if not M.is_notebook(filepath) then
    vim.notify("Current buffer is not a Jupyter notebook (.ipynb)", vim.log.levels.WARN)
    return nil
  end
  if vim.bo.modified then
    vim.cmd("write")
  end
  return filepath
end

---Converts the current notebook to PDF using quarto or jupyter nbconvert.
---@param output_format? string "pdf" | "typst" | "webpdf"
function M.export_to_pdf(output_format)
  local filepath = current_notebook()
  if not filepath then return end

  local ok, molten = pcall(require, "molten.status")
  if ok and molten.initialized() == "Molten" then
    pcall(vim.cmd, "MoltenExportOutput!")
  end

  local cmd
  if vim.fn.executable("quarto") == 1 then
    cmd = { "quarto", "render", filepath, "--to", output_format or "pdf", "--no-execute" }
  elseif vim.fn.executable("jupyter") == 1 then
    cmd = { "jupyter", "nbconvert", "--to", output_format == "typst" and "pdf" or (output_format or "pdf"), filepath }
  else
    vim.notify("Neither 'quarto' nor 'jupyter' executable found in PATH.", vim.log.levels.ERROR)
    return
  end

  vim.notify("Exporting " .. vim.fs.basename(filepath) .. " to PDF...", vim.log.levels.INFO)
  vim.system(cmd, { text = true }, vim.schedule_wrap(function(res)
    if res.code == 0 then
      local pdf_path = vim.fn.fnamemodify(filepath, ":r") .. ".pdf"
      vim.notify("Exported successfully to " .. vim.fs.basename(pdf_path), vim.log.levels.INFO)
    else
      local err_msg = res.stderr ~= "" and res.stderr or res.stdout
      vim.notify("Failed to export notebook to PDF:\n" .. err_msg, vim.log.levels.ERROR)
    end
  end))
end

---Clears all outputs from the current Jupyter notebook on disk and reloads it.
function M.clear_outputs()
  local filepath = current_notebook()
  if not filepath then return end
  if vim.fn.executable("jupyter") ~= 1 then
    vim.notify("'jupyter' executable not found in PATH to clear outputs.", vim.log.levels.ERROR)
    return
  end

  local res = vim.system({ "jupyter", "nbconvert", "--clear-output", "--inplace", filepath }, { text = true }):wait()
  if res.code ~= 0 then
    vim.notify("Failed to clear outputs: " .. res.stderr, vim.log.levels.ERROR)
    return
  end
  
  M.hide_output()
  vim.cmd("edit!")
  vim.notify("Cleared all outputs in " .. vim.fs.basename(filepath), vim.log.levels.INFO)
end

return M
