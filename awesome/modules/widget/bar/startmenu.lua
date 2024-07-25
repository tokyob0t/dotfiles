local bful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local utils = require("utils.init")
local dpi = utils.dpi

local function start_button(s)
	return wibox.widget({
		{
			image = bful.awesome_icon,
			widget = wibox.widget.imagebox,
			valign = "center",
			forced_height = dpi(32),
			forced_width = dpi(32),
			resize = true,
			clip_shape = utils.rrect(dpi(5)),
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
		widget = wibox.container.margin,
	})
end

return start_button
