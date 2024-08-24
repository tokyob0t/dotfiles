local bful = require("beautiful")

---@type wibox
local wibox = require("wibox")
local widget = wibox.widget
local cter = wibox.container

local cpu_progress = require(... .. ".cpu_progress")

return function()
	local cpu = cpu_progress()

	return widget({
		{ cpu, layout = wibox.layout.flex.horizontal },
		widget = cter.background,
		bg = bful.bg_normal,
	})
end
