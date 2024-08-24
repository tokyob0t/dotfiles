local bful = require("beautiful")
---@type wibox
local wibox = require("wibox")
local utils = require("utils.init")

---@type fun(icon_name: string, func: fun(dev: UPowerGlib.Device):boolean): wibox.widget
local chart = require(... .. ".chart")
local cter = wibox.container

--local bluetooth = require("services.gnomebluetooth")
--utils.notify(#bluetooth:get_devices())

return function()
	local mouse_bat = chart("input-mouse-symbolic", function(dev)
		return string.find(string.lower(dev.model), "mouse") ~= nil
	end)

	local laptop_bat = chart("laptop-symbolic", function(dev)
		return dev:get_object_path() == "/org/freedesktop/UPower/devices/battery_BAT1"
	end)

	return {
		{
			{
				laptop_bat,
				mouse_bat,
				chart("", function()
					return false
				end),
				chart("", function()
					return false
				end),
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(20),
			},
			valign = "center",
			widget = cter.place,
		},
		bg = bful.bg_normal,
		widget = cter.background,
	}
end
