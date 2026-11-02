---Keep Molten images in the persistent output pane using image.nvim's image objects.
local M = {}
local patched = false

---Find the notebook output pane in the current tab.
local function output_window()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.w[win].is_molten_right_pane then
			return win
		end
	end
end

---Find an image by the path or identifier passed through Molten.
local function find_image(identifier)
	for _, img in ipairs(require("image").get_images()) do
		if img.original_path == identifier or img.path == identifier or img.id == identifier then
			return img
		end
	end
end

---Install the two hooks needed because Molten manages floating output windows.
function M.setup()
	if patched then
		return
	end
	local ok, molten = pcall(require, "load_image_nvim")
	if not ok then
		return
	end
	local api = molten.image_api
	local render, clear = api.render, api.clear

	api.render = function(identifier, geometry)
		local win = output_window()
		local img = find_image(identifier)
		if win and img and img.buffer == vim.api.nvim_win_get_buf(win) then
			img.window = win
		end
		return render(identifier, geometry)
	end

	api.clear = function(identifier)
		local win = output_window()
		local img = find_image(identifier)
		if win and img and img.buffer == vim.api.nvim_win_get_buf(win) then
			return
		end
		return clear(identifier)
	end
	patched = true
end

return M
