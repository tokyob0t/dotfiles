local screen = screen
local awful = require("awful")
local user = require("user")
local wibox = require("wibox")
local utils = require("utils.init")
local dpi = utils.dpi

local launcher = require("modules.widget.launcher")

local systray = require(... .. ".tray")
local tasklist = require(... .. ".tasklist")
local activeclient = require(... .. ".activeclient")
local startmenu = require(... .. ".startmenu")
--local mic_icon = require("modules.widget.bar.microphone")

screen.connect_signal("request::desktop_decoration", function(s)
	awful.tag(user.Tags, s, awful.layout.layouts[1])

	s.mypromptbox = awful.widget.prompt()
	s.mylauncher = launcher(s)

	s.mylayoutbox = awful.widget.layoutbox({
		screen = s,
		buttons = {
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
		},
	})

	s.mytasklist = tasklist(s)
	s.activeclient = activeclient(s)
	s.startmenu = startmenu(s)
	s.systray = systray
	s.battery_icon = require("modules.widget.bar.battery")
	s.network_icon = require("modules.widget.bar.network")
	s.volume_icon = require("modules.widget.bar.volume")
	--s.mic_icon = mic_icon
	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "bottom",
		screen = s,
		height = dpi(60),
		widget = {
			{
				{
					s.activeclient,
					s.mypromptbox,
					spacing = 10,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					s.startmenu,
					s.mytasklist,
					spacing = 10,
					layout = wibox.layout.fixed.horizontal,
				},
				{
					{
						s.systray,
						s.network_icon,
						s.volume_icon,
						s.mic_icon,
						s.battery_icon,
						{
							format = "%H:%M %p\n%d/%m/%Y",
							widget = wibox.widget.textclock,
							halign = "right",
							font = "Segoe UI Variable " .. dpi(9),
						},
						s.mylayoutbox,
						spacing = 10,
						layout = wibox.layout.fixed.horizontal,
					},
					halign = "right",
					valign = "center",
					widget = wibox.container.place,
				},
				layout = wibox.layout.align.horizontal,
				expand = "outside",
			},
			margins = dpi(5),
			widget = wibox.container.margin,
		},
	})
end)
