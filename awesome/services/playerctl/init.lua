local utils = require("utils.init")
local Playerctl = utils.Playerctl

---@class manager: GearsObject_GObject, Playerctl.PlayerManager
local manager = utils.gearsify(Playerctl.PlayerManager())

manager._class.on_name_appeared = function(_, ...)
	manager:manage_player(Playerctl.Player.new_from_name(...))
	return manager:emit_signal("name-appeared", ...)
end

manager._class.on_name_vanished = function(_, ...)
	return manager:emit_signal("name-vanished", ...)
end

manager._class.on_player_appeared = function(_, ...)
	return manager:emit_signal("player-appeared", ...)
end

manager._class.on_player_vanished = function(_, ...)
	return manager:emit_signal("player-vanished", ...)
end

for _, value in ipairs(manager._class.player_names) do
	manager:manage_player(Playerctl.Player.new_from_name(value))
end

return manager
