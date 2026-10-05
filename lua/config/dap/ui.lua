---Configure DAP UI windows and listeners.

local M = {}

local listener_id = "dapui_config"

---Close the DAP UI.
local function close_ui()
	require("dapui").close()
end

---Set up DAP UI layout and lifecycle hooks.
function M.setup()
	local dap = require("dap")
	local dapui = require("dapui")

	dapui.setup({
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

	dap.listeners.after.event_initialized[listener_id] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated[listener_id] = close_ui
	dap.listeners.before.event_exited[listener_id] = close_ui
	dap.listeners.before.disconnect[listener_id] = close_ui
end

return M
