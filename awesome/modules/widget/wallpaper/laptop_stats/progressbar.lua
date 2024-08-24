---@type wibox
local wibox = require("wibox")
local utils = require("utils.init")

local widget = wibox.widget
local cter = wibox.container
local bful = require("beautiful")

return function(name, min, max)
	local w_name = {
		id = "textbox1",
		widget = widget.textbox,
		text = name,
	}
	local w_min_max = {
		id = "textbox2",
		widget = widget.textbox,
		text = tostring(min) .. "/" .. tostring(max),
	}
	local w_bar = {
		id = "progressbar",
		widget = widget.progressbar,
		value = 0,
		min_value = 0,
		max_value = 100,
		shape = utils.rrect(20),
	}
	return widget({
		w_bar,
		{ w_name, w_min_max, layout = wibox.layout.flex.horizontal },
		layout = wibox.layout.flex.vertical,
	})
end
