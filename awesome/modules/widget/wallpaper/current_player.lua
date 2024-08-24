local playerctl = require("services.playerctl")
local utils = require("utils.init")
---@type theme
local bful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local Player = require("services.playerctl.player")
local rubato = require("lib.rubato")

---@type wibox
local wibox = require("wibox")
local widget = wibox.widget
local cter = wibox.container

local cover_path = require("user").Home .. "/artUrl.png"
local bg_normal_semi = bful.transparentize(bful.bg_normal, 0.5)

return function()
	---@class recent_player: GearsObject_GObject, Playerctl.Player
	local recent_player

	---@param n string
	local icon = function(n)
		return utils.lookup_icon({ icon_name = n, size = 32, recolor = bful.fg_normal })
	end

	local my_cover = {
		{
			id = "my_cover",
			widget = widget.imagebox,
			image = utils.lookup_icon({ icon_name = "music-note-symbolic", recolor = bful.fg_minimize }),
			halign = "center",
			valign = "center",
			forced_height = dpi(120),
			forced_width = dpi(120),
			vertical_fit_policy = "fit",
		},
		bg = bful.bg_focus,
		widget = cter.background,
	}

	local my_title = {
		{
			id = "my_title",
			widget = widget.textbox,
			markup = "<b>No Media</b>",
			halign = "center",
		},
		expand = true,
		layout = cter.scroll.horizontal,
		max_size = 200,
		step_function = cter.scroll.step_functions.waiting_nonlinear_back_and_forth,
		fps = 144,
		speed = 100,
	}

	local my_artist = {
		{
			id = "my_artist",
			widget = widget.textbox,
			markup = "No Media",
			halign = "center",
		},
		expand = true,
		layout = cter.scroll.horizontal,
		max_size = 150,
		step_function = cter.scroll.step_functions.waiting_nonlinear_back_and_forth,
		fps = 144,
		speed = 100,
	}

	local my_buttons = {
		{
			widget = widget.imagebox,
			image = icon("seek-backward-large-symbolic"),
			forced_width = dpi(20),
			forced_height = dpi(20),
			buttons = {
				awful.button({}, 1, function()
					if recent_player ~= nil and recent_player.can_go_previous then
						recent_player:previous()
					end
				end),
			},
		},
		{
			id = "playback_icon",
			widget = widget.imagebox,
			image = icon("pause-large-symbolic"),
			forced_width = dpi(30),
			forced_height = dpi(30),
			buttons = {
				awful.button({}, 1, function()
					if recent_player ~= nil and recent_player.can_play then
						recent_player:play_pause()
					end
				end),
			},
		},
		{
			widget = widget.imagebox,
			forced_width = dpi(20),
			forced_height = dpi(20),
			image = icon("seek-forward-large-symbolic"),
			buttons = {
				awful.button({}, 1, function()
					if recent_player ~= nil and recent_player.can_go_next then
						recent_player:next()
					end
				end),
			},
		},
		layout = wibox.layout.flex.horizontal,
		spacing = dpi(20),
	}

	local w = widget({
		{
			{
				my_cover,
				{
					{
						my_title,
						my_artist,
						forced_width = dpi(130),
						layout = wibox.layout.fixed.vertical,
						point = { x = dpi(10), y = dpi(90) },
					},
					layout = wibox.layout.manual,
				},
				layout = wibox.layout.stack,
			},
			{
				{
					utils.table.override(my_buttons, {
						point = { x = dpi(20), y = dpi(90) },
					}),
					layout = wibox.layout.manual,
				},
				id = "buttons_stack",
				widget = cter.background,
				bg = bg_normal_semi,
			},
			layout = wibox.layout.stack,
		},
		widget = cter.background,
	})

	local title = w:get_children_by_id("my_title")[1]
	local artist = w:get_children_by_id("my_artist")[1]
	local cover = w:get_children_by_id("my_cover")[1]
	cover._set_image = function(self, new_img)
		if new_img ~= nil then
			if new_img == "string" then
				new_img = gears.surface.load_uncached(new_img)
			end

			local width, height = gears.surface.get_size(new_img)
			local new_w, new_h = 0, 0

			if width > 150 then
				new_w = (width - 150) / 2
			end
			if height > 150 then
				new_h = (height - 150) / 2
			end

			if new_h > 0 or new_w > 0 then
				new_img = gears.surface.crop_surface({
					surface = new_img,
					left = 100,
					right = 200,
					bottom = 1000,
					top = new_h,
				})
			end
		end
		return wibox.widget.imagebox.set_image(self, new_img)
	end

	local playback_icon = w:get_children_by_id("playback_icon")[1]
	local buttons_stack = w:get_children_by_id("buttons_stack")[1]

	w.anim = {
		opacity = rubato.timed({
			pos = 0,
			duration = 0.25,
			subscribed = function(p)
				buttons_stack.opacity = p
			end,
		}),
	}
	w:connect_signal("mouse::enter", function()
		w.anim.opacity.target = 1
	end)
	w:connect_signal("mouse::leave", function()
		w.anim.opacity.target = 0
	end)

	local update_metadata = function()
		if recent_player ~= nil then
			local artUrl = recent_player:print_metadata_prop("mpris:artUrl") or ""

			if string.match(artUrl, "file://") then
				cover.image = gears.surface.load_uncached(string.sub(artUrl, 8))
			elseif string.match(artUrl, "https://") then
				bash.popen("curl -L -s " .. artUrl .. " -o " .. cover_path, nil, nil, function()
					cover.image = gears.surface.load_uncached(cover_path)
				end)
			else
				cover.image = utils.lookup_icon({ icon_name = "music-note-symbolic", recolor = bful.fg_minimize })
			end
			title.markup = string.format("<b>%s</b>", recent_player:get_title() or "No Media")
			artist.markup = recent_player:get_artist() or "No Media"
		else
			title.markup = "<b>No Media</b>"
			artist.markup = "No Media"
			cover.image = utils.lookup_icon({ icon_name = "music-note-symbolic", recolor = bful.fg_minimize })
		end
		collectgarbage("collect")
	end

	local update_playback_status = function()
		if recent_player ~= nil then
			local s = recent_player.playback_status
			if s == "PLAYING" then
				playback_icon.image = icon("pause-large-symbolic")
			elseif s == "PAUSED" then
				playback_icon.image = icon("play-large-symbolic")
			elseif s == "STOPPED" then
				playback_icon.image = icon("stop-large-symbolic")
			end
		else
		end
	end

	local connect = function()
		recent_player:connect_signal("property::metadata", update_metadata)
		recent_player:connect_signal("property::playback_status", update_playback_status)
	end

	local disconnect = function()
		recent_player:disconnect_signal("property::metadata", update_metadata)
		recent_player:disconnect_signal("property::playback_status", update_playback_status)
	end

	playerctl:connect_signal("player-vanished", function(_, p)
		if p == recent_player._class then
			disconnect()

			if #playerctl.players >= 1 then
				recent_player = Player.new(playerctl.players[#playerctl.players])
				connect()
			else
				recent_player = nil
			end

			update_metadata()
			update_playback_status()
		end
	end)

	playerctl:connect_signal("player-appeared", function(_, p)
		if recent_player ~= nil then
			disconnect()
		end
		recent_player = Player.new(p)
		connect()
		update_metadata()
		update_playback_status()
	end)

	if #playerctl.players > 0 then
		recent_player = Player.new(playerctl.players[#playerctl.players])
		connect()
	end

	update_metadata()
	update_playback_status()

	return w
end
