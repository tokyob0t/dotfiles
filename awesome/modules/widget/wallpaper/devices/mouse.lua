local upower = require("utils.upower")
local utils = require("utils.init")

local fun_chart = require("modules.widget.wallpaper.devices.epic")

local mouse_chart = fun_chart("input-mouse-symbolic")

local chart = mouse_chart:get_children_by_id("my_chart")[1]
local textbox = mouse_chart:get_children_by_id("my_textbox")[1]
local icon = mouse_chart:get_children_by_id("my_icon")[1]
local charging_icon = mouse_chart:get_children_by_id("my_charging_icon")[1]

local battery

local update = function()
	if battery ~= nil then
		chart.value = battery.percentage
		textbox.text = battery.percentage .. "%"
		textbox.visible = true
		icon.visible = true
	else
		chart.value = 0
		textbox.visible = false
		icon.visible = false
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
	if type(string.find(dev.model, "mouse")) == "number" then
		battery = utils.gobject_to_gearsobject(dev)
	end
end

upower:connect_signal("device-added", function(_, dev)
	if type(string.find(dev.model, "mouse")) == "number" then
		battery = utils.gobject_to_gearsobject(dev)
		connect()
		update()
	end
end)

upower:connect_signal("device-removed", function(_, path)
	if battery and battery:get_object_path() == path then
		utils.notify("disconnect")
		disconnect()
		update()
	end
end)

return mouse_chart
