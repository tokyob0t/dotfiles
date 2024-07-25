local wibox = require("wibox")
local utils = require("utils.init")
local dpi = utils.dpi
local bful = require("beautiful")

return function(icon_name)
	local my_charging_icon = {
		id = "my_charging_icon",
		image = utils.lookup_icon({ icon_name = "camera-flash-symbolic", recolor = bful.fg_normal, size = 16 }),
		widget = wibox.widget.imagebox,
		forced_width = dpi(16),
		forced_height = dpi(16),
		visible = false,
	}

	local my_icon = {
		id = "my_icon",
		image = utils.lookup_icon({ icon_name = icon_name, recolor = bful.fg_normal }),
		widget = wibox.widget.imagebox,
		forced_width = dpi(32),
		forced_height = dpi(32),
		visible = false,
	}

	local my_chart = {
		{
			{
				my_icon,
				margins = dpi(16),
				widget = wibox.container.margin,
			},
			id = "my_chart",
			widget = wibox.container.arcchart,
			colors = bful.arcchart_color,
			rounded_edge = true,
			thickness = dpi(5),
			min_value = 0,
			max_value = 100,
			forced_width = dpi(75),
			forced_height = dpi(75),
			start_angle = 4.7,
		},
		{
			{
				my_charging_icon,
				widget = wibox.container.margin,
				top = -dpi(5),
			},
			widget = wibox.container.place,
			halign = "center",
			valign = "top",
		},
		layout = wibox.layout.stack,
	}

	local my_textbox = {
		id = "my_textbox",
		text = "100%",
		widget = wibox.widget.textbox,
		halign = "center",
		visible = false,
	}

	return wibox.widget({
		my_chart,
		my_textbox,
		spacing = dpi(10),
		layout = wibox.layout.fixed.vertical,
	})
end
