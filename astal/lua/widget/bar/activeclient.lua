local Hyprland <const> = astal.require("AstalHyprland")

return function()
	local hypr <const> = Hyprland.get_default()

	return Widget.GtkScrolledWindow({
		hexpand = true,
		vexpand = true,
		Widget.Box({
			orientation = "VERTICAL",
			valign = "CENTER",
			Widget.Label({
				halign = "START",
				class_name = "bar-label subtitle",
				setup = function(self)
					self:hook(hypr, "event", function()
						local c = hypr.focused_client
						if c then
							self.label = c.initial_class
						else
							self.label = "Desktop"
						end
					end)
				end,
			}),
			Widget.Label({
				halign = "START",
				class_name = "bar-label title",
				setup = function(self)
					self:hook(hypr, "event", function()
						local c = hypr.focused_client
						if c then
							self.label = c.title
						else
							self.label = string.format("Workspace %d", hypr.focused_workspace.id)
						end
					end)
				end,
			}),
		}),
	})
end
