local bful = require("beautiful")
local awful = require("awful")
local utils = require("utils.init")
local wibox = require("wibox")
local widget = wibox.widget
local cter = wibox.container

return function(s)
	return {
		{
			image = bful.awesome_icon,
			widget = widget.imagebox,
			valign = "center",
			forced_height = dpi(32),
			forced_width = dpi(32),
			resize = true,
			--clip_shape = utils.rrect(6),
			buttons = {
				awful.button({}, 4, function()
					awful.tag.viewprev(s)
				end),
				awful.button({}, 5, function()
					awful.tag.viewnext(s)
				end),
			},
		},
		margins = dpi(5),
		widget = cter.margin,
	}
end
