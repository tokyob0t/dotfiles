local wibox = require("wibox")
local awful = require("awful")
local utils = require("utils.init")
local bful = require("beautiful")
local dpi = utils.dpi

local systray = wibox.widget({
	{
		{
			base_size = dpi(16),
			widget = wibox.widget.systray,
		},
		layout = wibox.layout.flex.horizontal,
		valign = "center",
	},
	widget = wibox.container.place,
	visible = false,
})

local go_next_symbolic = utils.lookup_icon({ icon_name = "go-next-symbolic", recolor = bful.fg_normal })
local go_previous_symbolic = utils.lookup_icon({ icon_name = "go-previous-symbolic", recolor = bful.fg_normal })

local indicator = wibox.widget({
	image = go_next_symbolic,
	widget = wibox.widget.imagebox,
	valign = "center",
	forced_width = dpi(16),
	forced_height = dpi(16),
})

indicator.buttons = {
	awful.button({}, 1, function()
		if systray.visible then
			systray.visible = false
			indicator.image = go_next_symbolic
		else
			systray.visible = true
			indicator.image = go_previous_symbolic
		end
	end),
}

return wibox.widget({
	{
		systray,
		indicator,
		layout = wibox.layout.fixed.horizontal,
	},
	widget = wibox.container.place,
	valign = "center",
})
