---Central Telescope configuration and custom pickers.

local M = {}

local picker_theme = {
	border = true,
	prompt_title = false,
	results_title = false,
	preview_title = false,
	get_status_text = function()
		return ""
	end,
	sorting_strategy = "ascending",
	layout_config = {
		prompt_position = "top",
		preview_width = 0.6,
		width = 0.8,
		height = 0.8,
	},
}

---Merge overrides into the shared Telescope picker theme.
---@param opts table|nil
---@return table
function M.theme(opts)
	return vim.tbl_deep_extend("force", {}, picker_theme, opts or {})
end

---Configure Telescope defaults and picker-specific options.
function M.setup()
	local actions = require("telescope.actions")

	require("telescope").setup({
		defaults = {
			border = true,
			mappings = {
				i = {
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
				},
			},
			prompt_prefix = "   Search: ",
			entry_prefix = " ",
			selection_caret = " ",
		},
		pickers = {
			find_files = M.theme(),
			live_grep = M.theme(),
			diagnostics = M.theme(),
			lsp_references = M.theme(),
			lsp_definitions = M.theme(),
			lsp_implementations = M.theme(),
			lsp_document_symbols = M.theme(),
			lsp_workspace_symbols = M.theme(),
		},
	})
end

---Open Telescope builtin by name.
---@param name string
---@param opts table|nil
local function builtin(name, opts)
	require("telescope.builtin")[name](opts)
end

function M.find_files()
	builtin("find_files")
end

function M.live_grep()
	builtin("live_grep")
end

function M.diagnostics()
	builtin("diagnostics")
end

function M.lsp_definitions()
	builtin("lsp_definitions")
end

function M.lsp_references()
	builtin("lsp_references")
end

function M.lsp_implementations()
	builtin("lsp_implementations")
end

local function table_picker(opts)
	require("telescope.pickers").new({}, M.theme(opts)):find()
end

---Open the spelling suggestion picker for the current word.
function M.spell_suggestions()
	local bufnr = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local word = vim.fn.expand("<cword>")
	local suggestions = vim.fn.spellsuggest(word)
	if #suggestions == 0 then
		return
	end

	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local finders = require("telescope.finders")
	local sorters = require("telescope.sorters")

	table_picker({
		prompt_title = "Spelling Suggestions",
		finder = finders.new_table({ results = suggestions }),
		sorter = sorters.get_generic_fuzzy_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local choice = action_state.get_selected_entry().value
				actions.close(prompt_bufnr)

				local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
				local new_line = line:gsub("%f[%w]" .. word .. "%f[%W]", choice)
				vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
			end)
			return true
		end,
	})
end

---Open a Harpoon file picker.
---@param file_paths string[]
function M.harpoon_files(file_paths)
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")

	table_picker({
		finder = finders.new_table({ results = file_paths }),
		previewer = conf.file_previewer({}),
		sorter = conf.generic_sorter({}),
	})
end

local function debug_options()
	if vim.bo.filetype == "java" then
		return { "Debug Main Application", "Debug Tests" }
	end

	return { "Continue", "Restart", "Terminate" }
end

local function run_debug_option(choice)
	local dap = require("dap")
	local dapui = require("dapui")

	if choice == "Debug Tests" then
		local ok, jdtls_dap = pcall(require, "jdtls.dap")
		if ok then
			jdtls_dap.test_class()
		else
			vim.notify("jdtls.dap not available", vim.log.levels.WARN)
		end
		return
	end

	if choice == "Debug Main Application" or choice == "Continue" then
		dap.continue()
		return
	end

	if choice == "Restart" then
		dap.restart()
		return
	end

	dap.terminate()
	dapui.close()
end

---Open the DAP action picker.
function M.debug_actions()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")

	table_picker({
		prompt_title = "Debug Options",
		finder = finders.new_table({ results = debug_options() }),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				run_debug_option(selection[1])
			end)
			return true
		end,
	})
end

return M
