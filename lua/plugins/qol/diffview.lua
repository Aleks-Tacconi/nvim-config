---Keeps Diffview foreground colors while removing opaque backgrounds.
local function make_transparent()
	for _, name in ipairs({
		"DiffviewNormal",
		"DiffviewFilePanelSelected",
		"DiffviewFilePanelTitle",
		"DiffviewFilePanelCounter",
		"DiffviewFilePanelRootPath",
		"DiffviewFilePanelPath",
		"DiffviewFilePanelFileName",
		"DiffviewFilePanelInsertions",
		"DiffviewFilePanelDeletions",
		"DiffviewFilePanelConflicts",
		"DiffviewFolderName",
		"DiffviewFolderSign",
		"DiffviewNonText",
		"DiffviewSignColumn",
		"DiffviewStatusAdded",
		"DiffviewStatusUntracked",
		"DiffviewStatusModified",
		"DiffviewStatusRenamed",
		"DiffviewStatusCopied",
		"DiffviewStatusTypeChanged",
		"DiffviewStatusUnmerged",
		"DiffviewStatusUnknown",
		"DiffviewStatusDeleted",
		"DiffviewStatusBroken",
		"DiffviewStatusIgnored",
		"DiffviewStatusLine",
		"DiffviewStatusLineNC",
		"DiffviewEndOfBuffer",
		"DiffviewDiffDeleteDim",
	}) do
		local highlight = vim.api.nvim_get_hl(0, { name = name, link = false })
		highlight.bg = nil
		vim.api.nvim_set_hl(0, name, highlight)
	end

	vim.api.nvim_set_hl(0, "DiffviewCursorLine", {})
end

---Styles Diffview's contextual split labels without affecting other windows.
local function style_winbar(_, winid)
	vim.wo[winid].foldenable = false
	vim.wo[winid].foldcolumn = "0"

	local winhighlight = vim.wo[winid].winhighlight
	if not winhighlight:find("CursorLine:DiffviewCursorLine", 1, true) then
		local separator = winhighlight == "" and "" or ","
		vim.wo[winid].winhighlight = winhighlight
			.. separator
			.. "CursorLine:DiffviewCursorLine,WinBar:DiffviewFilePanelTitle,WinBarNC:DiffviewDim1"
	end
end

local saved_showtabline

---Hides the global tabline while the active tab is a Diffview.
local function hide_tabline()
	if saved_showtabline == nil then
		saved_showtabline = vim.o.showtabline
	end
	vim.o.showtabline = 0
end

---Restores the tabline after leaving Diffview.
local function restore_tabline()
	if saved_showtabline ~= nil then
		vim.o.showtabline = saved_showtabline
		saved_showtabline = nil
	end
end

---Renders one compact file row with status and change stats.
local function render_file(component, depth, hl)
	local file = component.context
	local name_hl = file.active and "DiffviewFilePanelSelected" or "DiffviewFilePanelFileName"

	component:add_text(file.status .. " ", hl.get_git_hl(file.status))
	component:add_text(string.rep("  ", depth))
	component:add_text(file.basename, name_hl)
	if file.stats and file.stats.additions then
		component:add_text(" +" .. file.stats.additions, "DiffviewFilePanelInsertions")
		component:add_text(" -" .. file.stats.deletions, "DiffviewFilePanelDeletions")
	end
	component:ln()
end

---Renders collapsible folders with minimal ASCII markers.
local function render_tree(component, depth, hl)
	if component.name == "file" then
		render_file(component, depth + 1, hl)
		return
	end
	if component.name ~= "directory" then
		return
	end

	local directory = component.components[1]
	local items = component.components[2]
	directory:add_text(string.rep("  ", depth))
	directory:add_text(component.context.collapsed and "+ " or "- ", "DiffviewNonText")
	directory:add_text(component.context.name .. "/", "DiffviewFolderName")
	directory:ln()

	if not component.context.collapsed then
		for _, item in ipairs(items.components) do
			render_tree(item, depth + 1, hl)
		end
	end
end

---Renders the selected panel information in a compact tree.
local function configure_file_panel(view)
	if view.class:name() ~= "DiffView" then
		return
	end

	view.panel.render = function(panel)
		if not panel.render_data or not panel.components then
			return
		end

		panel.render_data:clear()
		local hl = require("diffview.hl")
		for _, section in ipairs({
			{ "conflicting", "Conflicts", panel.files.conflicting, true },
			{ "working", "Changes", panel.files.working, false },
			{ "staged", "Staged", panel.files.staged, true },
		}) do
			if #section[3] > 0 then
				if section[4] then
					local title = panel.components[section[1]].title.comp
					title:add_text(section[2] .. " ", "DiffviewFilePanelTitle")
					title:add_line("(" .. #section[3] .. ")", "DiffviewFilePanelCounter")
				end
				for _, component in ipairs(panel.components[section[1]].files.comp.components) do
					render_tree(component, 0, hl)
				end
			end
		end
	end

	view.panel:render()
	view.panel:redraw()
end

---Applies the minimal UI when a Diffview opens.
local function on_view_opened(view)
	hide_tabline()
	configure_file_panel(view)
	view.panel:close()
end

---Keeps only the public Diffview commands used by this configuration.
local function trim_commands()
	for name in pairs(vim.api.nvim_get_commands({ builtin = false })) do
		if name:match("^Diffview") and name ~= "DiffviewOpen" and name ~= "DiffviewClose" then
			vim.api.nvim_del_user_command(name)
		end
	end
end

---Closes the complete Diffview after :q closes any of its windows.
local function close_view_on_quit()
	local pending_view
	local group = vim.api.nvim_create_augroup("diffview-close-on-quit", { clear = true })

	vim.api.nvim_create_autocmd("QuitPre", {
		group = group,
		callback = function()
			pending_view = require("diffview.lib").get_current_view()
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		callback = function()
			local view = pending_view
			pending_view = nil
			if not view then
				return
			end

			vim.schedule(function()
				if vim.api.nvim_tabpage_is_valid(view.tabpage) then
					vim.api.nvim_set_current_tabpage(view.tabpage)
					vim.cmd("DiffviewClose")
				end
			end)
		end,
	})
end

return {
	"sindrets/diffview.nvim",
	config = function()
		vim.opt.fillchars:append({ diff = " " })

		local actions = require("diffview.actions")
		local toggle_files = { "n", "<C-S-d>", actions.toggle_files, { desc = "Toggle file panel" } }

		require("diffview").setup({
			enhanced_diff_hl = true,
			use_icons = false,
			show_help_hints = false,
			view = {
				default = { winbar_info = true },
				file_history = { winbar_info = true },
			},
			file_panel = {
				listing_style = "tree",
				tree_options = {
					flatten_dirs = true,
					folder_statuses = "never",
				},
				win_config = {
					width = 32,
					win_opts = {
						colorcolumn = "",
						foldcolumn = "0",
						signcolumn = "no",
					},
				},
			},
			keymaps = {
				view = { toggle_files },
				file_panel = { toggle_files },
				file_history_panel = { toggle_files },
			},
			hooks = {
				diff_buf_win_enter = style_winbar,
				view_opened = on_view_opened,
				view_enter = hide_tabline,
				view_leave = restore_tabline,
				view_closed = restore_tabline,
			},
		})
		trim_commands()
		close_view_on_quit()

		make_transparent()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("diffview-transparent", { clear = true }),
			callback = make_transparent,
		})
	end,
}
