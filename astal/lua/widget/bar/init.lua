local Workspaces <const> = require(... .. ".workspaces")
local Clock <const> = require(... .. ".clock")
local ActiveClient <const> = require(... .. ".activeclient")
local Tray <const> = require(... .. ".tray")
local Indicators <const> = require(... .. ".indicators")
local Music <const> = require(... .. ".music")

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
