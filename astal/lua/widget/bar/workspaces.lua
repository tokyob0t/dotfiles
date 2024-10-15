local Hyprland = astal.require("AstalHyprland")
local map = require("lua.lib").map

local wp_count = 9
local wp_button_size = 15
local wp_button_thickness = 4.5
local wp_button_size_css = rem(35)

return function()
	local hypr = Hyprland.get_default()

	---@type table<number, 1>
	local wp_ids = {}

	local update = function()
		wp_ids = {}
		for _, c in ipairs(hypr.clients) do
			local id = math.floor(c.workspace.id)
			if not wp_ids[id] then
				wp_ids[id] = 1
			end
		end
	end

	hypr.on_notify.clients = update
	hypr["on_client-moved"] = update

	local wp_buttons = {}

	for i = 1, wp_count do
		table.insert(wp_buttons, i)
	end

	local wp_button_box = Widget.Box({
		halign = "CENTER",
		valign = "CENTER",
		class_name = "bar-box",
		width_request = wp_button_size * wp_count,
		map(wp_buttons, function(i)
			return Widget.Button({
				valign = "CENTER",
				setup = function(self)
					local update = function()
						if wp_ids[i] then
							self.class_name = ""
								.. ternary(not wp_ids[i - 1], "right ", "")
								.. ternary(not wp_ids[i + 1], "left ", "")
								.. "bg flat workspace-button"
						else
							self.class_name = "flat workspace-button"
						end
					end
					self:hook(hypr, "notify::clients", update)
					self:hook(hypr, "client-moved", update)
				end,
				on_click_release = function()
					return hypr:message_async(string.format("dispatch workspace %d", i))
				end,
				Widget.DrawingArea({
					halign = "CENTER",
					valign = "CENTER",
					setup = function(self)
						local update = function()
							if wp_ids[i] then
								self.class_name = "circle active"
							else
								self.class_name = "circle"
							end
						end
						self:hook(hypr, "notify::clients", update)
						self:hook(hypr, "client-moved", update)
					end,
					width_request = wp_button_size,
					height_request = wp_button_size,
					on_draw = function(self, cr)
						local GdkRGBA = self:get_style_context():get_property("color", Gtk.StateFlags.NORMAL).value
						local size = wp_button_size
						local thickness = wp_button_thickness
						local radius = (size - thickness) / 2

						cr:set_line_width(thickness)
						cr:set_source_rgba(GdkRGBA.red, GdkRGBA.green, GdkRGBA.blue, GdkRGBA.alpha)
						cr:arc(size / 2, size / 2, radius, 0, 2 * math.pi)
						cr:stroke()
					end,
				}),
			})
		end),
	})

	local wp_indicator_box = Widget.Box({
		valign = "CENTER",
		hexpand = true,
		Widget.Box({
			class_name = "wp-indicator",
			valign = "CENTER",
			halign = "CENTER",
			css = bind(hypr, "focused-workspace"):as(function(wp)
				return string.format(
					"margin-left: %.4frem;",
					wp_button_size_css * (wp.id - 1) + rem(ternary(wp.id < wp_count, wp.id, wp_count))
				)
			end),
		}),
	})

	hypr:notify("clients")

	return Widget.Overlay({
		valign = "CENTER",
		setup = function(self)
			self:set_overlay_pass_through(wp_indicator_box, true)
		end,
		overlays = { wp_indicator_box },
		wp_button_box,
	})
end
