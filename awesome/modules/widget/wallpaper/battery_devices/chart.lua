local wibox = require("wibox")
local utils = require("utils.init")
local bful = require("beautiful")
local upower = require("services.upower")
local widget = wibox.widget
local cter = wibox.container

return function(icon_name, func)
	local my_charging_icon = {
		{
			{
				{
					image = utils.lookup_icon({
						icon_name = "camera-flash-symbolic",
						recolor = bful.bg_normal,
						size = 32,
					}),
					widget = widget.imagebox,
					forced_width = dpi(22),
					forced_height = dpi(22),
				},
				widget = cter.place,
			},
			{
				{
					image = utils.lookup_icon({
						icon_name = "camera-flash-symbolic",
						recolor = bful.fg_normal,
						size = 16,
					}),
					widget = widget.imagebox,
					forced_width = dpi(16),
					forced_height = dpi(16),
				},
				widget = cter.place,
			},
			layout = wibox.layout.stack,
		},
		widget = cter.margin,
		top = -dpi(8),
		id = "my_charging_icon",
		visible = false,
	}

	local my_icon = {
		id = "my_icon",
		image = utils.lookup_icon({ icon_name = icon_name, recolor = bful.fg_normal }),
		widget = widget.imagebox,
		forced_width = dpi(32),
		forced_height = dpi(32),
		visible = false,
	}

	local my_chart = {
		{
			{
				my_icon,
				margins = dpi(16),
				widget = cter.margin,
			},
			id = "my_chart",
			widget = cter.arcchart,
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
			my_charging_icon,
			widget = cter.place,
			halign = "center",
			valign = "top",
		},
		layout = wibox.layout.stack,
	}

	local my_textbox = {
		id = "my_textbox",
		text = "100%",
		widget = widget.textbox,
		halign = "center",
		visible = false,
		font = "Segoe UI Variable 1000 10",
	}

	local w = widget({
		my_chart,
		my_textbox,
		spacing = dpi(10),
		layout = wibox.layout.fixed.vertical,
	})

	local chart = w:get_children_by_id("my_chart")[1]
	local textbox = w:get_children_by_id("my_textbox")[1]
	local icon = w:get_children_by_id("my_icon")[1]
	local charging_icon = w:get_children_by_id("my_charging_icon")[1]

	local battery

	local update = function()
		if battery ~= nil then
			textbox.visible = true
			icon.visible = true
			charging_icon.visible = battery.state == 1 or battery.percentage == 100

			chart.value = battery.percentage
			textbox.text = battery.percentage .. "%"
			chart.colors = bful.arcchart_color
		else
			textbox.visible = false
			icon.visible = false
			charging_icon.visible = false

			chart.colors = { bful.bg_focus }
			chart.value = 0
		end
	end

	local connect = function()
		battery:connect_signal("property::percentage", update)
		battery:connect_signal("property::state", update)
		battery:emit_signal("property::percentage")
	end

	local disconnect = function()
		battery:disconnect_signal("property::percentage", update)
		battery:disconnect_signal("property::state", update)
		battery = nil
	end

	for _, dev in pairs(upower:get_devices()) do
		if func(dev) then
			battery = utils.gearsify(dev)
			connect()
			update()
		end
	end

	upower:connect_signal("device-added", function(_, dev)
		if battery == nil and func(dev) then
			battery = utils.gearsify(dev)
			connect()
			update()
		end
	end)

	upower:connect_signal("device-removed", function(_, path)
		if battery ~= nil and battery:get_object_path() == path then
			disconnect()
			update()
		end
	end)

	return w
end
