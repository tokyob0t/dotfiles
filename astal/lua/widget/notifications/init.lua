local timeout <const> = astal.timeout
local Notifd <const> = astal.require("AstalNotifd")
local notifd <const> = Notifd.get_default()
local map = require("lua.lib").map
local popup_timeout = 5000

local notif_item = function(n)
	local app_name = Widget.Label({
		label = n.app_name,
		class_name = "name",
	})

	local summary = Widget.Label({
		label = n.summary,
		class_name = "summary",
		halign = "START",
		wrap = true,
		xalign = 0,
		max_width_chars = 70,
	})

	local body = Widget.Label({
		label = n.body,
		class_name = "body",
		halign = "START",
		wrap = true,
		xalign = 0,
		max_width_chars = 130,
	})

	local app_icon = Widget.Icon({
		icon = lookup_icon({ n.app_name, "application-x-executable" }),
		class_name = string.format(
			"icon %s",
			ternary(string.find(n.app_name, "-symbolic", 0, true) ~= nil, "symbolic", "")
		),
	})

	local image_path

	if n:get_hint("image-path") then
		image_path = n:get_hint("image-path"):get_data_as_bytes():get_data()
	else
		image_path = n.app_icon
	end

	local image = Widget.Icon({
		class_name = "image",
		valign = "CENTER",
		visible = image_path and #image_path > 1,
		icon = ternary(image_path and #image_path > 1, image_path, nil),
	})

	return Widget.EventBox({
		on_click_release = function(this)
			this:destroy()
		end,
		Widget.Box({
			orientation = "VERTICAL",
			Widget.Box({
				class_name = "notification-title",
				spacing = 10,
				app_icon,
				app_name,
				Widget.Icon({ icon = "window-close-symbolic", class_name = "icon", hexpand = true, halign = "END" }),
			}),
			Widget.Box({
				orientation = "VERTICAL",
				class_name = "notification-box",
				summary,
				body,
			}),
		}),
	})
end

return function(gdkmonitor)
	local windowname = string.format("notification-%d", gdkmonitor.display:get_n_monitors())
	return Widget.Window({
		class_name = "notifications",
		namespace = windowname,
		name = windowname,
		gdkmonitor = gdkmonitor,
		anchor = Astal.WindowAnchor.TOP,
		layer = "OVERLAY",
		visible = false,
		setup = function(self)
			local count = 0
			self:hook(notifd, "notified", function()
				count = count + 1
				self.visible = true
			end)
			self:hook(notifd, "resolved", function()
				count = count - 1
				if count == 0 then
					timeout(popup_timeout, function()
						self.visible = false
					end)
				end
			end)
		end,
		Widget.Box({
			orientation = "VERTICAL",
			class_name = "notifications-container",
			spacing = 10,
			css = string.format("padding-top: %.5frem", rem(10)),
			setup = function(self)
				self:hook(notifd, "notified", function(_, id)
					local n = notifd:get_notification(id)
					local e_timeout = ternary(n.expire_timeout > 0, n.expire_timeout * 1000, popup_timeout)
					local widget = notif_item(n)

					self:add(widget)

					timeout(e_timeout, function()
						widget:destroy()
					end)
				end)
			end,
		}),
	})
end
