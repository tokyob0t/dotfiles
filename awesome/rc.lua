#!/usr/bin/lua5.1

pcall(require, "luarocks.loader")

local naughty = require("naughty")

---@type awesome
awesome = awesome

naughty.connect_signal("request::display_error", function(message)
	naughty.notification({
		urgency = "critical",
		app_name = "Awesome",
		title = "Epic, you fucked up",
		message = message,
	})
end)

require("modules")
