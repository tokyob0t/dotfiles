local client = client
local tag = tag

local user = require("user")
local awful = require("awful")
--local naughty = require("naughty")
local utils = require("utils.init")
local bful = require("beautiful")

bful.init(user.AwmDir .. "theme/theme.lua")

local pam = require("lib.pam")

local success = pam.auth_current_user("31415926535")

utils.notify(success)

tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts(utils.table.map(user.Layouts, utils.GetLayout))
end)

if user.EnableStartupCMDS then
	for _, i in ipairs(user.StartupCMDS) do
		awful.spawn.easy_async(i, {
			stdout = function() end,
			stderr = function(line)
				utils.notify({ title = "Startup Command Failed :(", message = line })
			end,
		})
	end
end

if user.FocusFollowCursor then
	client.connect_signal("mouse::enter", function(c)
		c:activate({ context = "mouse_enter", raise = user.RaiseOnFocus })
	end)
end

if user.FloatingOnTop then
	client.connect_signal("property::floating", function(c)
		if c.floating then
			c.ontop = true
		end
	end)
end

if user.FocusOnSwitchTag then
	require("awful.autofocus")
end

client.connect_signal("property::maximized", function(c)
	if c.maximized then
		awful.titlebar.hide(c)
	else
		awful.titlebar.show(c)
	end
end)

client.connect_signal("request::manage", function(c)
	c.shape = utils.rrect(user.ClientRoundness)
end)
