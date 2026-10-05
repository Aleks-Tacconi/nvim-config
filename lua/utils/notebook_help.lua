---Floating cheatsheet for notebook keymaps and commands.
local M = {}

local LINES = {
  "# Notebook Shortcuts & Commands",
  "",
  "Keymaps are local to .ipynb buffers.",
  "",
  "## Code Execution",
  "  <space>rc       Run current code cell",
  "  <space>ra       Run current cell and all above",
  "  <space>rA       Run all cells in notebook",
  "  <space>r        Run visual selection (visual mode)",
  "",
  "## Kernel & Output Management",
  "  <space>mi       Initialize Molten kernel (:MoltenInit)",
  "  <space>os       Enter output window (q / <Esc> to close)",
  "  <space>oh       Hide output (re-shown on next run)",
  "  <space>ox       Export outputs into .ipynb (:MoltenExportOutput!)",
  "",
  "## Export & Utilities",
  "  <space>op       Export current notebook to PDF",
  "  :NewNotebook <name>     Create and open a new blank notebook",
  "  :NotebookToPdf [fmt]   Export to PDF (formats: pdf, typst, webpdf)",
  "  :NotebookClearOutputs  Strip all outputs from notebook file",
  "  :NotebookHelp          Open this cheatsheet",
}

---Opens the cheatsheet in a centered floating window.
function M.show()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, LINES)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false

  local width = math.min(74, math.floor(vim.o.columns * 0.85))
  local height = math.min(#LINES, math.floor(vim.o.lines * 0.85))
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Notebook Cheatsheet ",
    title_pos = "center",
  })
  require("utils.notebook").set_close_keymaps(buf)
end

return M
