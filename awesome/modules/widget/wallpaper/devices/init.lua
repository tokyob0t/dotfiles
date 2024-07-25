local bful = require("beautiful")
local wibox = require("wibox")
local utils = require("utils.init")
local dpi = utils.dpi

local mouse_bat = require(... .. ".mouse")
local laptop_bat = require(... .. ".laptop")

return {
	{
		{
			laptop_bat,
			mouse_bat,
			mouse_bat,
			mouse_bat,
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(20),
		},
		valign = "center",
		widget = wibox.container.place,
	},
	bg = bful.bg_normal,
	widget = wibox.container.background,
}
