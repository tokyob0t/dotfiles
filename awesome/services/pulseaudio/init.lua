---@type gears
local gears = require("gears")

local Stream = require("services.pulseaudio.stream")
local utils = require("utils.init")
local json = require("lib.json")

---@alias data { id: number, name: string, description: string, muted: boolean, volume: number, icon_name: string }

---@class pulseaudio: gears.object
local pulseaudio = gears.object({})
---@type Stream
pulseaudio.speaker = nil
---@type Stream
pulseaudio.microphone = nil
---@type table<number, Stream>
pulseaudio.applications = {}
---@type table<number, Stream>
pulseaudio.sinks = {}
---@type table<number, Stream>
pulseaudio.sources = {}
pulseaudio.filter = {
	all = function() end,
	currentsink = function() end,
	allsinks = function() end,
	currentsource = function() end,
	allsources = function() end,
	currentsinkinput = function() end,
	allsinkinputs = function() end,
	currentsourceoutput = function() end,
	allsourceouputs = function() end,
}

---
--- Common helper functions
---

pulseaudio.common = {}

---@param stdout string
---@return data
pulseaudio.common.get_data = function(stdout)
	local name, description, volume, muted, icon_name, ac_port, id
	local decoded_stdout = json.decode(stdout)

	id = decoded_stdout.index
	name = decoded_stdout.name
	description = decoded_stdout.description
	muted = decoded_stdout.mute
	volume = (
		(
			tonumber(string.sub(decoded_stdout.volume["front-left"].value_percent, 0, -2))
			+ tonumber(string.sub(decoded_stdout.volume["front-right"].value_percent, 0, -2))
		) / 2
	) or 0

	ac_port = utils.table.find(decoded_stdout.ports, function(p)
		return p.name == decoded_stdout.active_port
	end)

	if ac_port then
		-- Input
		if ac_port.type == "Mic" then
			icon_name = "audio-input-microphone-symbolic"
		elseif ac_port.type == "Headset" then
			icon_name = "audio-headset-symbolic"
		-- Output
		elseif ac_port.type == "Speaker" then
			icon_name = "audio-speakers-symbolic"
		elseif ac_port.type == "Headphones" then
			icon_name = "audio-headphones-symbolic"
		else
			icon_name = "audio-" .. string.lower(ac_port.type) .. "-symbolic"
		end
	else
		-- Generic x2
		icon_name = "audio-card-usb-symbolic"
	end

	return {
		id = id,
		name = name,
		description = description,
		muted = muted,
		volume = volume,
		icon_name = icon_name,
	}
end

---@param stdout string
---@param make_primary? boolean | nil
---@param s_type "sink" | "source" | "sink-input" | "source-output"
---@return nil
pulseaudio.common.new_from_data = function(stdout, make_primary, s_type)
	local data = pulseaudio.common.get_data(stdout)

	local new_stream = Stream.new({
		id = data.id,
		name = data.name,
		description = data.description,
		volume = data.volume,
		muted = data.muted,
		icon_name = data.icon_name,
		stream_type = s_type,
	})

	pulseaudio[s_type .. "s"][new_stream.id] = new_stream

	if make_primary == true then
		if s_type == "sink" then
			pulseaudio.speaker = new_stream
			pulseaudio:emit_signal("pulseaudio::speaker-changed", pulseaudio.speaker)
		elseif s_type == "source" then
			pulseaudio.microphone = new_stream
			pulseaudio:emit_signal("pulseaudio::microphone-changed", pulseaudio.microphone)
		end
	end

	pulseaudio:emit_signal(string.format("pulseaudio::%s-added", s_type), new_stream)
end

---@param id number
---@param s_type "sink" | "source" | "sink-input" | "source-output"
---@return nil
pulseaudio.common.new_from_id = function(id, s_type)
	return bash.get_output({
		"sh",
		"-c",
		string.format([[pactl --format=json list %s | jq ".[] | select (.index == %d )"]], s_type .. "s", id),
	}, function(stdout)
		return pulseaudio.common.new_from_data(stdout, false, s_type)
	end)
end

---@param id number
---@param s_type "sink" | "source" | "sink-input" | "source-output"
pulseaudio.common.update_from_id = function(id, s_type)
	---@type Stream | nil
	local stream = pulseaudio[s_type .. "s"][id]

	if stream then
		bash.get_output({
			"sh",
			"-c",
			string.format([[pactl --format=json list %s | jq ".[] | select (.index == %d )"]], s_type .. "s", id),
		}, function(stdout)
			local data = pulseaudio.common.get_data(stdout)

			for key, value in pairs(data) do
				if key == "mute" then
					if stream._class["muted"] ~= value then
						stream._class[key] = value
						stream:emit_signal("property::muted", value)
					end
				elseif stream._class[key] ~= value then
					stream._class[key] = value
					stream:emit_signal("property::" .. key, value)
				end
			end
		end)
	end
end

---@param id number
---@param s_type "sink" | "source" | "sink-input" | "source-output"
---@return nil
pulseaudio.common.remove_from_id = function(id, s_type)
	if pulseaudio[s_type .. "s"][id] then
		pulseaudio[s_type .. "s"][id] = nil
	end
end

---
--- Daemon
---

local pactl_subscribe = { "sh", "-c", [[pactl subscribe | grep --line-buffered -e "sink" -e "source" -e "server"]] }

local get_active_sink = {
	"sh",
	"-c",
	[[pactl --format=json list sinks | jq ".[] | select(.name == \"$(pactl --format=json info @DEFAULT_SINK@ | jq -r .default_sink_name)\")"]],
}

local get_active_source = {
	"sh",
	"-c",
	[[pactl --format=json list sources | jq ".[] | select(.name == \"$(pactl --format=json info @DEFAULT_SOURCE@ | jq -r .default_source_name)\")"]],
}

bash.run([[pkill -f 'pactl subscribe']], function()
	bash.get_output(get_active_sink, function(s)
		return pulseaudio.common.new_from_data(s, true, "sink")
	end)

	bash.get_output(get_active_source, function(s)
		return pulseaudio.common.new_from_data(s, true, "source")
	end)

	---

	bash.popen(pactl_subscribe, function(stdout)
		local parts, event, signal, device, id
		parts = utils.string.split(stdout)
		event, device, id = string.sub(parts[2], 2, -2), parts[4], tonumber(string.sub(parts[5], 2)) or -1
		signal = string.format("pulseaudio::%s-%s", device, event)

		---
		--- Devices
		---

		-- Sink
		if signal == "pulseaudio::sink-new" then
			pulseaudio.common.new_from_id(id, "sink")
		elseif signal == "pulseaudio::sink-remove" then
			pulseaudio.common.remove_from_id(id, "sink")
		elseif signal == "pulseaudio::sink-change" then
			pulseaudio.common.update_from_id(id, "sink")

		-- Source
		elseif signal == "pulseaudio::source-new" then
			pulseaudio.common.new_from_id(id, "source")
		elseif signal == "pulseaudio::source-remove" then
			pulseaudio.common.remove_from_id(id, "source")
		elseif signal == "pulseaudio::source-change" then
			pulseaudio.common.update_from_id(id, "source")

		---
		--- Applications
		---

		--- Sink
		elseif signal == "pulseaudio::sink-input-new" then
		elseif signal == "pulseaudio::sink-input-remove" then
		elseif signal == "pulseaudio::sink-input-change" then
		--- Source
		elseif signal == "pulseaudio::source-output-new" then
		elseif signal == "pulseaudio::source-output-remove" then
		elseif signal == "pulseaudio::source-output-change" then

		---
		--- Other
		---
		elseif signal == "pulseaudio::server-change" then
			bash.get_output(get_active_sink, function(s)
				return pulseaudio.common.new_from_data(s, true, "sink")
			end)

			bash.get_output(get_active_source, function(s)
				return pulseaudio.common.new_from_data(s, true, "source")
			end)
		else
			utils.notify("New signal dumbas " .. signal)
		end

		pulseaudio:emit_signal(signal)
	end)
end)

return pulseaudio
