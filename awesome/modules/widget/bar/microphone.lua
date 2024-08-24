local pulseaudio = require("services.pulseaudio")
local wibox = require("wibox")
local bful = require("beautiful")
local utils = require("utils.init")
local widget = wibox.widget

local volume_icon = widget({
	id = "icon_role",
	image = utils.lookup_icon({
		icon_name = "microphone-sensitivity-high-symbolic",
		recolor = bful.fg_normal,
		size = 16,
	}),
	widget = widget.imagebox,
	forced_height = dpi(16),
	forced_width = dpi(16),
	valign = "center",
})

volume_icon.icon_name = "microphone-sensitivity-high-symbolic"

local function get_icon(value)
	if value == 0 then
		return "microphone-sensitivity-muted-symbolic"
	elseif value < 30 then
		return "microphone-sensitivity-low-symbolic"
	elseif value < 65 then
		return "microphone-sensitivity-medium-symbolic"
	else
		return "microphone-sensitivity-high-symbolic"
	end
end

local function update_icon(s)
	local new_icon

	if s.muted == true then
		new_icon = get_icon(0)
	else
		new_icon = get_icon(s.volume)
	end

	if new_icon ~= volume_icon.icon_name then
		volume_icon.icon_name = new_icon
		volume_icon:get_children_by_id("icon_role")[1].image =
			utils.lookup_icon({ icon_name = volume_icon.icon_name, recolor = bful.fg_normal, size = 16 })
	end
end

local mic = pulseaudio.microphone

if mic then
	mic:connect_signal("property::muted", update_icon)
	mic:connect_signal("property::volume", update_icon)
	mic:emit_signal("property::muted", mic.muted)
end

---@param p pulseaudio
pulseaudio:connect_signal("pulseaudio::microphone-changed", function(p)
	if mic then
		mic:disconnect_signal("property::muted", update_icon)
		mic:disconnect_signal("property::volume", update_icon)
	end

	---@type Stream
	mic = p.microphone
	mic:connect_signal("property::muted", update_icon)
	mic:connect_signal("property::volume", update_icon)
	mic:emit_signal("property::muted", mic.muted)
end)

return volume_icon
