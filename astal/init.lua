require("lua.globals")

pcall(require, "luarocks.loader")

local App = astal.App

local config_dir = GLib.getenv("XDG_CONFIG_HOME") .. "/astal"
local cache_dir = GLib.getenv("XDG_CACHE_HOME") .. "/astal"

local scss = config_dir .. "/styles.scss"
local css = cache_dir .. "/styles.css"
local icons = config_dir .. "/icons"

astal.exec(string.format("sassc %s %s", scss, css))

local Bar = require("lua.widget.bar.init")
local Launcher = require("lua.widget.launcher.init")
local Notifications = require("lua.widget.notifications.init")
local Desktop = require("lua.widget.desktop.init")

local Windows = {
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
			Windows.desktop[gdkmonitor] = Desktop(gdkmonitor)
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
			.default(function()
				response("non ok")
			end)
			.process()
	end,
})
