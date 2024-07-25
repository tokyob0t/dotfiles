local utils = require("utils.init")
local bash = utils.bash
local gears = require("gears")

---@class Stream: gears.object
---@field _class Stream
---@field id number
---@field name string
---@field description string
---@field volume number
---@field muted boolean
---@field icon_name string
---@field stream_type "sink" | "source" | "sink-input" | "source-output"
local Stream = {
	id = -1,
	name = "",
	description = "",
	volume = 0,
	muted = false,
	icon_name = "",
	stream_type = "sink",
}

---@param args { id: number, name: string, description: string, volume: number, muted: boolean, icon_name: string, stream_type: "sink" | "source" | "sink-input" | "source-output"}
---@return Stream
Stream.new = function(args)
	local self = gears.object({
		class = setmetatable({}, { __index = Stream }),
		enable_properties = true,
		enable_auto_signals = true,
	})

	self._class.id = args.id
	self._class.name = args.name
	self._class.description = args.description
	self._class.volume = args.volume
	self._class.muted = args.muted
	self._class.icon_name = args.icon_name
	self._class.stream_type = args.stream_type

	return self
end

---@param self Stream
---@param volume number
---@return nil
Stream.set_volume = function(self, volume)
	if self.volume == volume then
		return
	end
	self._class.volume = volume
	bash.run(string.format("pactl set-%s-volume %d %d%%", self.stream_type, self.id, self._class.volume))
	return self:emit_signal("property::volume", self._class.volume)
end

---@param self Stream
---@param muted boolean | 0 | 1
---@return nil
Stream.set_muted = function(self, muted)
	local state = utils.t(type(muted) == "boolean", utils.t(muted == true, 1, 0), utils.t(muted == 1, 1, 0))

	if state == 0 then
		self._class.muted = false
	elseif state == 1 then
		self._class.muted = true
	else
		return
	end

	bash.run(string.format("pactl set-%s-mute %d %d", self.stream_type, self.id, state))
	return self:emit_signal("property::muted", self._class.muted)
end

setmetatable(Stream, {
	---@param cls Stream
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

return Stream
