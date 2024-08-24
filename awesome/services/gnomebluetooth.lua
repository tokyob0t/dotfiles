local utils = require("utils.init")

---@class gnome_bluetooth: GearsObject_GObject, GnomeBluetooth.Client
local gnome_bluetooth = utils.gearsify(utils.GnomeBluetooth.Client.new())

gnome_bluetooth._class.on_device_added = function(_, ...)
	return gnome_bluetooth:emit_signal("device-added", ...)
end

gnome_bluetooth._class.on_device_removed = function(_, ...)
	return gnome_bluetooth:emit_signal("device-removed", ...)
end

---@return GnomeBluetooth.Device[]
gnome_bluetooth.get_devices = function(self)
	local devices = self._class:get_devices()
	local new_devices = {}

	for i = 0, devices.n_items, 1 do
		table.insert(new_devices, devices:get_item(i))
	end

	return new_devices
end

return gnome_bluetooth
