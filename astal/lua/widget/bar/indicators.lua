local Network = astal.require("AstalNetwork")
local Battery = astal.require("AstalBattery")
local Wp = astal.require("AstalWp")

local WifiIcon = function()
	local wifi = Network.get_default().wifi

	return Widget.Icon({
		class_name = "icon",
		tooltip_text = bind(wifi, "ssid"):as(tostring),
		icon = bind(wifi, "icon-name"),
	})
end

local VolumeIcon = function()
	local speaker = Wp.get_default().audio.default_speaker
	local scroll_revealed = Variable()

	return Widget.EventBox({
		on_hover = function()
			scroll_revealed:set(true)
		end,
		on_hover_lost = function()
			scroll_revealed:set(false)
		end,
		tooltip_text = bind(speaker, "volume"):as(function(v)
			return string.format("%.0f%%", v * 100)
		end),
		Widget.Box({
			Widget.Button({
				on_click_release = function()
					speaker.mute = not speaker.mute
				end,
				Widget.Icon({
					class_name = "icon",
					icon = bind(speaker, "volume-icon"),
				}),
			}),
			Widget.GtkRevealer({
				reveal_child = scroll_revealed(),
				transition_type = "SLIDE_LEFT",
				valign = "CENTER",
				Widget.Slider({
					class_name = "volume-slider",
					on_dragged = function(self)
						speaker.volume = self.value
					end,
					hexpand = true,
					value = bind(speaker, "volume"),
				}),
			}),
		}),
	})
end

local BatteryIcon = function()
	local bat = Battery.get_default()

	return Widget.Icon({
		class_name = "icon",
		icon = bind(bat, "icon-name"),
		tooltip_text = bind(bat, "percentage"):as(function(p)
			return string.format("%.0f%%", p * 100)
		end),
	})
end

return function()
	return Widget.Box({
		class_name = "bar-box",
		valign = "CENTER",
		Widget.Box({
			class_name = "indicator-cter",
			valign = "CENTER",
			halign = "CENTER",
			hexpand = true,
			spacing = 10,
			WifiIcon(),
			VolumeIcon(),
			BatteryIcon(),
		}),
	})
end
