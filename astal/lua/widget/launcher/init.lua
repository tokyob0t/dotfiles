-- thx
-- https://github.com/Aylur/dotfiles/blob/main/ags/widget/launcher/AppLauncher.ts
local App = astal.App

local AppList = require("lua.widget.launcher.apps")
local IconList = require("lua.widget.launcher.iconlibrary")
local FileList = require("lua.widget.launcher.nautilus")
local GamesList = require("lua.widget.launcher.cartridges")
local CalcList = require("lua.widget.launcher.gnomecalculator")

return function(gdkmonitor)
	-- local windowname = string.format("launcher-%d", gdkmonitor.display:get_n_monitors())
	local windowname = "launcher"

	local app_list = AppList()
	local icon_list = IconList()
	local file_list = FileList()
	local games_list = GamesList()
	local calc_list = CalcList()

	local entry = Widget.Entry({
		class_name = "flat",
		halign = "CENTER",
		placeholder_text = "Search...",
		on_changed = function(self)
			local text = string.lower(tostring(self.text) or "")
			if string.sub(text, 1, 1) ~= ":" then
				app_list.filter(text)
				icon_list:filter(text)
				file_list:filter(text)
				games_list:filter(text)
				calc_list:filter(text)
			end
		end,
		on_activate = function()
			if false then
			else
				app_list.launch_first()
			end
			return astal.exec_async("astal -i astal-lua -t launcher")
		end,
	})

	return Widget.Window({
		gdkmonitor = gdkmonitor,
		namespace = windowname,
		name = windowname,
		class_name = "launcher",
		keymode = "ON_DEMAND",
		anchor = Astal.WindowAnchor.TOP
			+ Astal.WindowAnchor.LEFT
			+ Astal.WindowAnchor.RIGHT
			+ Astal.WindowAnchor.BOTTOM,
		visible = false,
		application = App,
		setup = function(self)
			self:hook(self, "notify::visible", function()
				entry.text = ""
				if self.visible then
					entry:set_position(-1)
					entry:select_region(0, -1)
					entry:grab_focus()
				end
			end)
		end,
		on_key_press_event = function(self, event)
			if event.keyval == Gdk.KEY_Escape then
				self.visible = false
			end
		end,
		Widget.Box({
			hexpand = true,
			vexpand = true,
			orientation = "VERTICAL",
			spacing = 10,
			entry,
			Widget.GtkScrolledWindow({
				vexpand = true,
				hexpand = true,
				Widget.Box({
					hexpand = true,
					vexpand = true,
					orientation = "VERTICAL",
					halign = "CENTER",
					app_list.item_list,
					icon_list.item_list,
					file_list.item_list,
					games_list.item_list,
					calc_list.item_list,
				}),
			}),
		}),
	})
end
