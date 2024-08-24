local bful = require("beautiful")
local gears = require("gears")

require("utils.bash")

---@param size number
---@param s screen?
---@return number
dpi = function(size, s)
	return bful.xresources.apply_dpi(size, s)
end

---@param timeout number
---@param callback function?
---@return gears.timer
wait = function(timeout, callback)
	timeout = timeout or 1
	callback = callback or function() end

	return gears.timer({
		timeout = timeout,
		autostart = true,
		single_shot = true,
		callback = callback,
	})
end

---@param timeout number
---@param callback function?
---@return gears.timer
interval = function(timeout, callback)
	return gears.timer({
		timeout = timeout,
		autostart = true,
		callback = callback,
	})
end

---@param condition boolean
---@param ifTrue any
---@param ifFalse any
---@return any
ternary = function(condition, ifTrue, ifFalse)
	if condition then
		return ifTrue
	else
		return ifFalse
	end
end

require(... .. ".settings")
require(... .. ".widget")
require(... .. ".keybindings")
require(... .. ".rules")
