#!/bin/lua5.4

require("lua.globals")

local App <const> = astal.App

local config_dir <const> = GLib.getenv("XDG_CONFIG_HOME") .. "/astal"
local cache_dir <const> = GLib.getenv("XDG_CACHE_HOME") .. "/astal"

local scss <const> = config_dir .. "/styles.scss"
local css <const> = cache_dir .. "/styles.css"
local icons <const> = config_dir .. "/icons"

astal.exec(string.format("sassc %s %s", scss, css))

local Bar <const> = require("lua.widget.bar")
local Launcher <const> = require("lua.widget.launcher")
local Notifications <const> = require("lua.widget.notifications")
local Desktop <const> = require("lua.widget.desktop")

local Windows <const> = {
	bars = {},
	launchers = {},
	notifications = {},
	desktop = {},
}

App:start({
	icons = icons,
	css = css,
	instance_name = "astal-lua",
	main = function()
		for _, gdkmonitor in ipairs(App.monitors) do
			Windows.bars[gdkmonitor] = Bar(gdkmonitor)
			Windows.launchers[gdkmonitor] = Launcher(gdkmonitor)
			Windows.notifications[gdkmonitor] = Notifications(gdkmonitor)
			Windows.desktop[gdkmonitor] = Desktop(gdkmonitor)
		end

		App.on_monitor_added = function(_, gdkmonitor)
			Windows.bars[gdkmonitor] = Bar(gdkmonitor)
		end

		App.on_monitor_removed = function(_, gdkmonitor)
			if Windows.bars[gdkmonitor] then
				Windows.bars[gdkmonitor]:destroy()
				Windows.bars[gdkmonitor] = nil
			end
		end
	end,
	request_handler = function(request, response)
		switch(request)
			.case("launcher", function()
				for _, value in pairs(Windows.launchers) do
					value.visible = not value.visible
				end
				response("ok")
			end)
			.default(function()
				response("non ok")
			end)
			.process()
	end,
})
