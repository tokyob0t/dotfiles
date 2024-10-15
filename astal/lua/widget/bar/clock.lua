return function()
	local time = Variable("00:00"):poll(6000, function()
		return GLib.DateTime.new_now_local():format("%H:%M")
	end)

	local date = Variable("00:00"):poll(3600000, function()
		return GLib.DateTime.new_now_local():format("%a %d %b")
	end)

	return Widget.Box({
		class_name = "bar-box clock-box",
		halign = "CENTER",
		valign = "CENTER",
		spacing = 5,
		Widget.Label({
			label = time(),
			halign = "CENTER",
			hexpand = true,
			class_name = "bar-label",
		}),
		Widget.Icon({
			icon = "dot-symbolic",
			class_name = "symbolic",
			valign = "CENTER",
		}),
		Widget.Label({
			label = date(),
			halign = "CENTER",
			hexpand = true,
			class_name = "bar-label",
		}),
		on_destroy = function()
			time:drop()
			date:drop()
		end,
	})
end
