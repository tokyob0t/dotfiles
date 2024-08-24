local awful = require("awful")
local bful = require("beautiful")
local utils = require("utils.init")
---@type wibox
local wibox = require("wibox")
local widget = wibox.widget

local battery_devices = require(... .. ".battery_devices")
local current_player = require(... .. ".current_player")
local current_tag = require(... .. ".current_tag")
local laptop_stats = require(... .. ".laptop_stats")
local cava_widget = require(... .. ".cava_widget")
local active_awm = {
	{
		widget = widget.textbox,
		markup = "<span font_weight='500' font_size='15pt'>Activate Awesome</span>",
	},
	{
		widget = widget.textbox,
		markup = "<span font_weight='400' font_size='13pt'>Go to Settings to activate Awesome.</span>",
	},
	layout = wibox.layout.fixed.vertical,
}

---@param s screen | table
screen.connect_signal("request::wallpaper", function(s)
	s.wallpapa = {
		image = bful.wallpaper,
		widget = widget.imagebox,
		halign = "center",
		valign = "center",
		horizontal_fit_policy = "fill",
		vertical_fit_policy = "none",
	}

	s.cava_widget = cava_widget(s)
	s.bat_devices = battery_devices()
	s.current_player = current_player()
	s.current_tag = current_tag(s)
	s.laptop_stats = laptop_stats()
	s.activate_awm = active_awm

	awful.placement.maximize(
		wibox({
			screen = s,
			type = "desktop",
			x = s.geometry.x,
			y = s.geometry.y,
			forced_width = s.geometry.width,
			forced_height = s.geometry.height,
			visible = true,
			below = true,
			widget = {
				s.wallpapa,
				{
					utils.table.override(s.bat_devices, {
						point = { x = dpi(25), y = dpi(25) },
						forced_width = dpi(400),
						forced_height = dpi(150),
						shape = utils.rrect(30),
					}),
					utils.table.override(s.current_player, {
						point = { x = dpi(435), y = dpi(25) },
						forced_width = dpi(150),
						forced_height = dpi(150),
						shape = utils.rrect(30),
					}),
					--utils.table.override(s.laptop_stats, {
					--	point = { x = dpi(845), y = dpi(25) },
					--	forced_width = dpi(400),
					--	forced_height = dpi(150),
					--	shape = utils.rrect(30),
					--}),
					utils.table.override(s.cava_widget, {
						point = { x = dpi(595), y = dpi(25) },
						forced_width = dpi(400),
						forced_height = dpi(150),
						shape = utils.rrect(30),
					}),
					utils.table.override(s.activate_awm, {
						point = {
							x = (s.geometry.width / 2) + dpi(1200, s) / 2,
							y = (s.geometry.width / 2) - dpi(50, s),
						},
					}),
					---
					--utils.table.override(s.current_tag, {
					--	point = {
					--		x = (s.geometry.width / 2) - dpi(500, s) / 2,
					--		y = (s.geometry.width / 2) - dpi(50, s),
					--	},
					--	forced_width = dpi(500),
					--	forced_height = dpi(50),
					--	shape = utils.rrect(50),
					--}),
					---
					layout = wibox.layout.manual,
				},
				widget = wibox.layout.stack,
			},
		}),
		{ honor_workarea = true }
	)
end)
