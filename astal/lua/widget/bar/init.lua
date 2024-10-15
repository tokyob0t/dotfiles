local Workspaces = require("lua.widget.bar.workspaces")
local Clock = require("lua.widget.bar.clock")
local ActiveClient = require("lua.widget.bar.activeclient")
local Tray = require("lua.widget.bar.tray")
local Indicators = require("lua.widget.bar.indicators")
local Music = require("lua.widget.bar.music")

return function(gdkmonitor)
	local windowname = string.format("bar-%d", gdkmonitor.display:get_n_monitors())
	return Widget.Window({
		namespace = windowname,
		name = windowname,
		class_name = "bar",
		gdkmonitor = gdkmonitor,
		anchor = Astal.WindowAnchor.TOP + Astal.WindowAnchor.LEFT + Astal.WindowAnchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.CenterBox({
			class_name = "bar-centerbox",
			Widget.Box({
				ActiveClient(),
			}),
			Widget.Box({
				spacing = 5,
				Music(),
				Workspaces(),
				Clock(),
				Indicators(),
				Tray(),
			}),
			Widget.Box({}),
		}),
	})
end
