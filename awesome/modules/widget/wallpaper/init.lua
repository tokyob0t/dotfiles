local screen = screen
local awful = require("awful")
local bful = require("beautiful")
local wibox = require("wibox")
local playerctl = require("utils.playerctl")
local utils = require("utils.init")
local dpi = utils.dpi

screen.connect_signal("request::wallpaper", function(s)
	s.wallpapa = {
		upscale = true,
		downscale = true,
		image = bful.wallpaper,
		widget = wibox.widget.imagebox,
	}

	s.bat_devices = require("modules.widget.wallpaper.devices")

	return awful.wallpaper({
		screen = s,
		widget = {
			s.wallpapa,
			{
				utils.table.override(s.bat_devices, {
					point = { x = dpi(25), y = dpi(25) },
					forced_width = dpi(400),
					forced_height = dpi(150),
					shape = utils.rrect(dpi(30)),
				}),
				layout = wibox.layout.manual,
			},
			widget = wibox.layout.stack,
		},
	})
end)
