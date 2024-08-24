local utils = require("utils.init")

---@class network_manager: GearsObject_GObject, NM.Client
local network_manager = utils.gearsify(utils.NM.Client.new())

network_manager._class.on_active_connection_added = function(_, ...)
	return network_manager:emit_signal("active-connection-added", ...)
end

network_manager._class.on_active_connection_removed = function(_, ...)
	return network_manager:emit_signal("active-connection-removed", ...)
end

network_manager._class.on_any_device_added = function(_, ...)
	return network_manager:emit_signal("any-device-added", ...)
end

network_manager._class.on_any_device_removed = function(_, ...)
	return network_manager:emit_signal("any-device-removed", ...)
end

network_manager._class.on_connection_added = function(_, ...)
	return network_manager:emit_signal("connection-added", ...)
end

network_manager._class.on_connection_removed = function(_, ...)
	return network_manager:emit_signal("connection-removed", ...)
end

network_manager._class.on_device_added = function(_, ...)
	return network_manager:emit_signal("device-added", ...)
end

network_manager._class.on_device_removed = function(_, ...)
	return network_manager:emit_signal("device-removed", ...)
end

network_manager._class.on_permission_changed = function(_, ...)
	return network_manager:emit_signal("permission-changed", ...)
end

return network_manager
