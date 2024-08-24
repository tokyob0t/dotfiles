local upower = require("services.upower")
local wibox = require("wibox")
local bful = require("beautiful")
local utils = require("utils.init")
local widget = wibox.widget

local battery_widget = widget({
	id = "icon",
	image = utils.lookup_icon({ icon_name = "battery-missing-symbolic", recolor = bful.fg_normal }),
	widget = widget.imagebox,
	forced_height = dpi(16),
	forced_width = dpi(16),
	valign = "center",
})

local battery = upower:get_display_device()

if battery ~= nil then
	local function update(self)
		local p, icon_name = math.floor((self.percentage + 5) / 10) * 10, "battery-full-charged-symbolic"

		if p ~= 100 then
			icon_name = string.format("battery-level-%s%s-symbolic", p, ternary(self.state == 1, "-charging", ""))
		end

		battery_widget:get_children_by_id("icon")[1].image = utils.lookup_icon({
			icon_name = icon_name,
			recolor = bful.fg_normal,
		})
	end

	---@class battery: GearsObject_GObject, UPowerGlib.Device
	battery = utils.gearsify(battery)

	battery:connect_signal("property::percentage", update)
	battery:connect_signal("property::state", update)

	battery:emit_signal("property::percentage")
end

return battery_widget
