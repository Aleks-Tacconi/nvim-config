local dbg_win = nil
local dbg_buf = nil

local function open_debug_help()
	if dbg_win and vim.api.nvim_win_is_valid(dbg_win) then
		return
	end

	dbg_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(dbg_buf, 0, -1, false, {
		"   b1 │ Continue",
		"   b2 │ Step into",
		"   b3 │ Step over",
		"   b4 │ Step out",
		"   b5 │ Step back",
		"   b6 │ Restart",
		"   b7 │ Terminate",
		"   b8 │ Disconnect",
		"   b9 │ Close",
		"   bh │ Toggle",
	})

	vim.bo[dbg_buf].modifiable = false
	vim.bo[dbg_buf].bufhidden = "wipe"
	vim.bo[dbg_buf].filetype = "markdown"

	local width = 24
	local height = 10

	dbg_win = vim.api.nvim_open_win(dbg_buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = 0,
		col = vim.o.columns - width - 2,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})
end

local function close_debug_help()
	if dbg_win and vim.api.nvim_win_is_valid(dbg_win) then
		vim.api.nvim_win_close(dbg_win, true)
	end
	dbg_win = nil
	dbg_buf = nil
end

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"mfussenegger/nvim-dap-python",
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>bt", desc = "Toggle breakpoint" },
		{ "<leader>bs", desc = "Debug session picker" },
		{ "<leader>b1", desc = "DAP continue" },
		{ "<leader>b9", desc = "DAP close" },
	},
	cmd = { "DapContinue", "DapToggleBreakpoint" },
	config = function()
		require("lazydev").setup({
			library = { "nvim-dap-ui" },
		})

		local dap = require("dap")
		local dapui = require("dapui")
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		-- dap actions
		vim.keymap.set("n", "<leader>wa", function()
			require("dapui").elements.watches.add()
		end)

		vim.keymap.set("v", "<leader>wa", function()
			require("dapui").elements.watches.add(vim.fn.expand("<cword>"))
		end)

		vim.keymap.set("n", "<leader>wd", function()
			require("dapui").elements.watches.remove()
		end)

		vim.keymap.set("n", "<leader>bt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>b1", dap.continue)
		vim.keymap.set("n", "<leader>b2", dap.step_into)
		vim.keymap.set("n", "<leader>b3", dap.step_over)
		vim.keymap.set("n", "<leader>b4", dap.step_out)
		vim.keymap.set("n", "<leader>b5", dap.step_back)
		vim.keymap.set("n", "<leader>b6", dap.restart)
		vim.keymap.set("n", "<leader>b7", dap.terminate)
		vim.keymap.set("n", "<leader>b8", dap.disconnect)
		vim.keymap.set("n", "<leader>b9", function()
			dap.terminate()
			dapui.close()
			close_debug_help()
		end)
		vim.keymap.set("n", "<leader>bh", function()
			if dbg_win and vim.api.nvim_win_is_valid(dbg_win) then
				close_debug_help()
			else
				open_debug_help()
			end
		end)

		vim.keymap.set("n", "<leader>bs", function()
			pickers
				.new({}, {
					prompt_title = "Debug Options",
					finder = finders.new_table({
						results = {
							"Debug Main Application",
							"Debug Tests",
						},
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)

							if selection[1] == "Debug Tests" then
								require("jdtls.dap").test_class()
							elseif selection[1] == "Debug Main Application" then
								dap.continue()
							end
						end)
						return true
					end,
				})
				:find()
		end)

		require("dapui").setup({
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.60 },
						{ id = "watches", size = 0.20 },
						{ id = "breakpoints", size = 0.20 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						{ id = "console", size = 0.60 },
						{ id = "repl", size = 0.40 },
					},
					size = 10,
					position = "bottom",
				},
			},
		})
		dap.listeners.after.attach.debug_help = function()
			open_debug_help()
		end
		dap.listeners.after.launch.debug_help = function()
			open_debug_help()
		end
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
			open_debug_help()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
			close_debug_help()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
			close_debug_help()
		end
		dap.listeners.before.disconnect["dapui_config"] = function()
			dapui.close()
			close_debug_help()
		end
	end,
}
