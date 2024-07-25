local upower = require("utils.upower")
local utils = require("utils.init")

local fun_chart = require("modules.widget.wallpaper.devices.epic")

local laptop_chart = fun_chart("laptop-symbolic")
local chart = laptop_chart:get_children_by_id("my_chart")[1]
local textbox = laptop_chart:get_children_by_id("my_textbox")[1]
local icon = laptop_chart:get_children_by_id("my_icon")[1]
local charging_icon = laptop_chart:get_children_by_id("my_charging_icon")[1]

---@class battery: UPowerGlib.Device, GearsObject_GObject
local battery = utils.gobject_to_gearsobject(upower:get_display_device())

---@param self battery
local update = function(self)
	chart.value = self.percentage
	textbox.text = self.percentage .. "%"
	charging_icon.visible = self.state == 1
	utils.notify(textbox.text)
end

if battery ~= nil then
	icon.visible = true
	textbox.visible = true
	---@class battery: GearsObject_GObject, UPowerGlib.Device

	battery:connect_signal("property::percentage", update)
	battery:connect_signal("property::state", update)

	battery:emit_signal("property::percentage", battery.percentage)
end

return laptop_chart
