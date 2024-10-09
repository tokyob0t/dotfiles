local App <const> = astal.App
local Tray <const> = astal.require("AstalTray")
local tray = Tray.get_default()
local map = require("lua.lib").map
local idle = require("lua.lib").idle

return function()
	return Widget.Box({
		spacing = 5,
		bind(tray, "items"):as(function(items)
			return map(items, function(item)
				if item.icon_theme_path ~= nil then
					App:add_icons(item.icon_theme_path)
				end

				local menu = item:create_menu()
				return Widget.Button({
					tooltip_markup = bind(item, "tooltip_markup"),
					class_name = "flat",
					valign = "CENTER",
					halign = "CENTER",
					on_click_release = function(self, event)
						switch(event.button)
							.case("PRIMARY", function()
								menu:activate()
							end)
							.case("SECONDARY", function()
								if menu ~= nil then
									menu:popup_at_widget(self, "SOUTH", "NORTH", nil)
								end
							end)
							.process()
					end,
					Widget.Icon({
						g_icon = bind(item, "gicon"),
					}),
				})
			end)
		end),
	})
end
