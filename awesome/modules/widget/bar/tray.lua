local wibox = require("wibox")
local awful = require("awful")
local utils = require("utils.init")
local bful = require("beautiful")
local widget = wibox.widget
local cter = wibox.container

local systray = widget({
	{
		{
			base_size = dpi(16),
			widget = widget.systray,
		},
		layout = wibox.layout.flex.horizontal,
		valign = "center",
	},
	widget = cter.place,
	visible = false,
})

local go_next_symbolic = utils.lookup_icon({ icon_name = "go-next-symbolic", recolor = bful.fg_normal })
local go_previous_symbolic = utils.lookup_icon({ icon_name = "go-previous-symbolic", recolor = bful.fg_normal })

local indicator = widget({
	image = go_next_symbolic,
	widget = widget.imagebox,
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

return widget({
	{
		systray,
		indicator,
		layout = wibox.layout.fixed.horizontal,
	},
	widget = cter.place,
	valign = "center",
})
