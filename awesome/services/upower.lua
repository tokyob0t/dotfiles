local utils = require("utils.init")
---https://lazka.github.io/pgi-docs/UPowerGlib-1.0/index.html
local UPowerGlib = utils.UPowerGlib

---@class upower: GearsObject_GObject, UPowerGlib.Client
local upower = utils.gearsify(UPowerGlib.Client.new())

upower._class.on_device_added = function(_, ...)
	return upower:emit_signal("device-added", ...)
end

upower._class.on_device_removed = function(_, ...)
	return upower:emit_signal("device-removed", ...)
end

return upower
