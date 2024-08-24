local pulseaudio = require("services.pulseaudio")
local wibox = require("wibox")
local bful = require("beautiful")
local utils = require("utils.init")
local widget = wibox.widget

local volume_icon = widget({
	id = "icon_role",
	image = utils.lookup_icon({ icon_name = "audio-volume-muted-symbolic", recolor = bful.fg_normal, size = 16 }),
	widget = widget.imagebox,
	forced_height = dpi(16),
	forced_width = dpi(16),
	valign = "center",
})

volume_icon.icon_name = "audio-volume-muted-symbolic"

local function get_icon(value)
	if value == 0 then
		return "audio-volume-muted-symbolic"
	elseif value < 30 then
		return "audio-volume-low-symbolic"
	elseif value < 65 then
		return "audio-volume-medium-symbolic"
	elseif value < 101 then
		return "audio-volume-high-symbolic"
	else
		return "audio-volume-overamplified-symbolic"
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

---@type Stream
local speaker = pulseaudio.speaker

if speaker then
	speaker:connect_signal("property::muted", update_icon)
	speaker:connect_signal("property::volume", update_icon)
	speaker:emit_signal("property::muted", speaker.muted)
end

pulseaudio:connect_signal("pulseaudio::speaker-changed", function(p)
	if speaker then
		speaker:disconnect_signal("property::muted", update_icon)
		speaker:disconnect_signal("property::volume", update_icon)
	end

	---@type Stream
	speaker = p.speaker
	speaker:connect_signal("property::muted", update_icon)
	speaker:connect_signal("property::volume", update_icon)
	speaker:emit_signal("property::muted", speaker.muted)
end)

return volume_icon
