local network = require("services.networkmanager")
local wibox = require("wibox")
local bful = require("beautiful")
local utils = require("utils.init")
local widget = wibox.widget

local network_icon = widget({
	id = "icon_role",
	image = utils.lookup_icon({ icon_name = "network-wireless-offline-symbolic", recolor = bful.fg_normal, size = 16 }),
	widget = widget.imagebox,
	forced_height = dpi(16),
	forced_width = dpi(16),
	valign = "center",
})

---@class wlo1: NM.Device, GearsObject_GObject
local wlo1
---@class ap: NM.AccessPoint, GearsObject_GObject
local ap

local function get_icon(value)
	if value <= 20 then
		return "network-wireless-signal-weak-symbolic"
	elseif value <= 50 then
		return "network-wireless-signal-ok-symbolic"
	elseif value <= 70 then
		return "network-wireless-signal-good-symbolic"
	else
		return "network-wireless-signal-excellent-symbolic"
	end
end

---@param self? NM.AccessPoint
local function update_widget(self)
	local icon_name = "network-wireless-signal-none-symbolic"

	if self then
		if wlo1.state == "ACTIVATED" then
			icon_name = get_icon(self.strength)
		elseif utils.table.contains({ "PREPARE", "IP_CONFIG", "CONFIG" }, wlo1.state) then
			icon_name = "network-wireless-acquiring-symbolic"
		end
	end

	network_icon:get_children_by_id("icon_role")[1].image =
		utils.lookup_icon({ icon_name = icon_name, recolor = bful.fg_normal })
end

---@param old ap
local function disconnect_all(old)
	if old ~= nil then
		old:disconnect_signal("property::strength", update_widget)
		update_widget()
	end
end

---@param new ap
local function connect_all(new)
	new:connect_signal("property::strength", update_widget)
	new:emit_signal("property::strength", new.strength)
	return utils.notify({
		icon_name = "network-wireless-acquiring-symbolic",
		title = "Network Activated",
		message = "Connected to " .. new.ssid,
	})
end

if network:get_device_by_iface("wlo1") then
	wlo1 = utils.gearsify(network:get_device_by_iface("wlo1"))

	wlo1:connect_signal("property::active-access-point", function(_, new_ap)
		if new_ap then
			disconnect_all(ap)

			ap = utils.gearsify(new_ap)
			ap.ssid = ap:get_ssid():get_data()

			connect_all(ap)
		else
			disconnect_all(ap)
		end
	end)

	wlo1:emit_signal("property::active-access-point", wlo1._class.active_access_point)
end

return network_icon
