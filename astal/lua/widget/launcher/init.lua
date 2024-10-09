local Apps <const> = astal.require("AstalApps")
local map = require("lua.lib").map

local apps = Apps.Apps({
	include_entry = true,
	include_executable = true,
})

local Entry
local item = function(app)
	return Widget.GtkRevealer({
		setup = function(self)
			local kwords = string.lower(table.concat({ app.name, app.description }, " "))

			self:hook(Entry, "changed", function()
				local text = string.lower(Entry.text or "")
				if text then
					self.reveal_child = string.find(kwords, text, 1, true)
				end
			end)
		end,
		reveal_child = true,
		transition_type = "SLIDE_UP",
		valign = "START",
		Widget.Button({
			class_name = "flat",
			valign = "START",
			on_key_press_event = function(_, event)
				if event.keyval == Gdk.KEY_Return then
					app:launch()
					astal.exec_async("astal -i astal-lua launcher")
				end
			end,
			Widget.Box({
				valign = "START",
				hexpand = true,
				Widget.Icon({
					icon = lookup_icon({ app.icon_name, "application-x-executable" }),
					class_name = "app-icon",
				}),
				Widget.Box({
					orientation = "VERTICAL",
					Widget.Label({
						label = app.name,
						class_name = "app-name",
						xalign = 0,
						wrap = true,
					}),
					Widget.Label({
						label = app.description,
						class_name = "app-desc",
						xalign = 0,
						wrap = true,
					}),
				}),
			}),
		}),
	})
end

return function(gdkmonitor)
	local windowname = string.format("launcher-%d", gdkmonitor.display:get_n_monitors())

	Entry = Widget.Entry({
		class_name = "flat",
		on_activate = function()
			print("a")
		end,
	})

	local apps_cter = Widget.Box({
		hexpand = true,
		vexpand = true,
		height_request = 500,
		orientation = "VERTICAL",
		class_name = "apps-cter",
		bind(apps, "list"):as(function(list)
			table.sort(list, function(a, b)
				return a.name < b.name
			end)
			return map(list, item)
		end),
	})

	return Widget.Window({
		gdkmonitor = gdkmonitor,
		namespace = windowname,
		name = windowname,
		class_name = "launcher",
		keymode = "ON_DEMAND",
		width_request = 400,
		height_request = 500,
		visible = false,
		setup = function(self)
			self:hook(self, "notify::visible", function()
				if self.visible then
					Entry:grab_focus()
				else
					Entry.text = ""
				end
			end)
		end,
		on_key_press_event = function(self, event)
			if event.keyval == Gdk.KEY_Escape then
				self.visible = false
			end
		end,
		Widget.Box({
			valign = "START",
			orientation = "VERTICAL",
			Entry,
			Widget.GtkScrolledWindow({
				vexpand = true,
				hexpand = true,
				height_request = 500,
				apps_cter,
			}),
		}),
	})
end
