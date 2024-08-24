local utils = require("utils.init")
local gears = require("gears")

---@class Player
local Player = {}

---@param p Playerctl.Player
Player.new = function(p)
	---@class self: GearsObject_GObject, Playerctl.Player
	local self = utils.gearsify(p)

	--self._class.on_exit = function() end
	self._class.on_loop_status = function(_, ...)
		return self:emit_signal("property::loop_status", ...)
	end

	self._class.on_metadata = function(_, ...)
		return self:emit_signal("property::metadata", ...)
	end
	self._class.on_playback_status = function(_, ...)
		return self:emit_signal("property::playback_status", ...)
	end
	self._class.on_seeked = function(_, ...)
		return self:emit_signal("property::seeked", ...)
	end
	self._class.on_shuffle = function(_, ...)
		return self:emit_signal("property::shuffle", ...)
	end
	self._class.on_volume = function(_, ...)
		return self:emit_signal("property::volume", ...)
	end

	return self
end

setmetatable(Player, {
	---@param cls Player
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

return Player
