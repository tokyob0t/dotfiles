local client = client

local awful = require("awful")
local user = require("user")

local hotkeys_popup = require("awful.hotkeys_popup")
local pulseaudio = require("utils.pulseaudio")

local utils = require("utils.init")
local bash = utils.bash
local Bind = utils.Bind

---@param direction string
local resize_by_direction = function(direction, c)
	local floating_resize_factor = 20
	local master_resize_factor = 0.01

	if not c then
		return
	end

	if c.floating or awful.layout.get(mouse.screen) == utils.GetLayout("floating") then
		if direction == "up" then
			c:relative_move(0, floating_resize_factor, 0, -floating_resize_factor * 2)
		elseif direction == "down" then
			c:relative_move(0, -floating_resize_factor, 0, floating_resize_factor * 2)
		elseif direction == "left" then
			c:relative_move(floating_resize_factor, 0, -floating_resize_factor * 2, 0)
		elseif direction == "right" then
			c:relative_move(-floating_resize_factor, 0, floating_resize_factor * 2, 0)
		end
	else
		if direction == "up" or direction == "right" then
			awful.tag.incmwfact(master_resize_factor)
		elseif direction == "down" or direction == "left" then
			awful.tag.incmwfact(-master_resize_factor)
		end
	end
end

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({ user.ModKey }, 1, function(c)
			if not c.floating then
				c.floating = true
            end
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ user.ModKey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

awful.keyboard.append_global_keybindings({
	---
	--- FN Keys
	---
	Bind({
		key = "XF86AudioMute",
		on_press = function()
			--bash.run("pactl set-sink-mute @DEFAULT_SINK@ toggle")
			pulseaudio.speaker.muted = not pulseaudio.speaker.muted
		end,
	}),
	Bind({
		key = "XF86AudioLowerVolume",
		on_press = function()
			local v = pulseaudio.speaker.volume - 5
			if v >= 0 then
				pulseaudio.speaker.volume = v
			end
		end,
	}),
	Bind({
		key = "XF86AudioRaiseVolume",
		on_press = function()
			local v = pulseaudio.speaker.volume + 5
			if v <= 100 then
				pulseaudio.speaker.volume = v
			end
		end,
	}),
	Bind({
		description = "Volume up",
		key = "XF86AudioMicMute",
		on_press = function()
			--bash.run("pactl set-source-mute @DEFAULT_SOURCE@ toggle")
			pulseaudio.microphone.muted = not pulseaudio.microphone.muted
		end,
	}),
	Bind({
		key = "XF86MonBrightnessDown",
		on_press = function()
			bash.run("brightnessctl set 5%-")
		end,
	}),
	Bind({
		key = "XF86MonBrightnessUp",
		on_press = function()
			bash.run("brightnessctl set 5%+")
		end,
	}),
	---
	--- Awesome related keybindings
	---
	Bind({
		group = "Awesome",
		description = "Show help",
		modifiers = { user.ModKey },
		key = "k",
		on_press = hotkeys_popup.show_help,
	}),
	Bind({
		group = "Awesome",
		description = "Reload awesome",
		modifiers = { user.ModKey, user.ShiftKey },
		key = "r",
		on_press = awesome.restart,
	}),
	Bind({
		group = "Awesome",
		description = "Quit awesome",
		modifiers = { user.ModKey, user.ShiftKey },
		key = "q",
		on_press = awesome.quit,
	}),
	---
	--- App related keybindings
	---
	Bind({
		group = "Apps",
		description = "File manager",
		modifiers = { user.ModKey },
		key = "e",
		on_press = function()
			awful.spawn(user.FileManager)
		end,
	}),
	Bind({
		group = "Apps",
		description = "Terminal emulator",
		modifiers = { user.ModKey },
		key = "t",
		on_press = function()
			awful.spawn(user.Terminal)
		end,
	}),
	Bind({
		group = "Apps",
		description = "Web Browser",
		modifiers = { user.ModKey },
		key = "f",
		on_press = function()
			awful.spawn(user.Browser)
		end,
	}),
	Bind({
		group = "Apps",
		description = "Launcher2",
		modifiers = { user.ModKey },
		key = "Return",
		on_press = function()
			local s = awful.screen.focused()
			s.mypromptbox:run()
		end,
	}),
	Bind({
		group = "Apps",
		description = "Launcher",
		modifiers = { user.ModKey },
		key = "r",
		on_press = function()
			local s = awful.screen.focused()
			s.mylauncher.visible = not s.mylauncher.visible
		end,
	}),
	---
	--- Tag related keybindings
	---
	Bind({
		group = "Tag",
		description = "View previous",
		modifiers = { user.CtrlKey, user.AltKey },
		key = "Left",
		on_press = awful.tag.viewprev,
	}),
	Bind({
		group = "Tag",
		description = "View next",
		modifiers = { user.CtrlKey, user.AltKey },
		key = "Right",
		on_press = awful.tag.viewnext,
	}),
	Bind({
		group = "Tag",
		description = "View only tag",
		modifiers = { user.ModKey },
		key = "numrow",
		on_press = function(i)
			local s = awful.screen.focused()
			if i <= #s.tags then
				s.tags[i]:view_only()
			end
		end,
	}),

	--
	-- Client Related Keybindings
	--

	Bind({
		group = "Client",
		description = "Focus client",
		modifiers = { user.ModKey },
		key = "arrows",
		---@param a string
		on_press = function(a)
			awful.client.focus.bydirection(string.lower(a), client.focus)
			if client.focus then
				client.focus:activate({ action = "mouse_center" })
			end
		end,
	}),
	Bind({
		group = "Client",
		description = "Move client",
		modifiers = { user.ModKey, user.AltKey },
		key = "arrows",
		on_press = function(a)
			awful.client.swap.bydirection(string.lower(a), client.focus)
		end,
	}),
	Bind({
		group = "Client",
		description = "Resize client",
		modifiers = { user.ModKey, user.ShiftKey },
		key = "arrows",
		on_press = function(a)
			resize_by_direction(string.lower(a), client.focus)
		end,
	}),

	Bind({
		group = "Client",
		description = "Focus previous client",
		modifiers = { user.AltKey },
		key = "Tab",
		on_press = function()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
	}),
	Bind({
		group = "Client",
		description = "Send client to tag",
		modifiers = { user.ModKey, user.ShiftKey },
		key = "numrow",
		---@param i number
		on_press = function(i)
			if client.focus then
				local s = awful.screen.focused()
				if i <= #s.tags then
					local tag = s.tags[i]
					client.focus:move_to_tag(tag)
					tag:view_only()
				end
			end
		end,
	}),
	Bind({
		group = "Client",
		description = "Send client to previous tag",
		modifiers = { user.CtrlKey, user.ModKey },
		key = "Left",
		on_press = function()
			if client.focus then
				local s = awful.screen.focused()
				local tag = s.selected_tag
				if tag then
					local prevTag = tag.index - 1

					if prevTag >= 1 then
						client.focus:move_to_tag(s.tags[prevTag])
						awful.tag.viewprev()
					end
				end
			end
		end,
	}),
	Bind({
		group = "Client",
		description = "Send client to next tag",
		modifiers = { user.CtrlKey, user.ModKey },
		key = "Right",
		on_press = function()
			if client.focus then
				local s = awful.screen.focused()
				local tag = s.selected_tag
				if tag then
					local nextTag = tag.index + 1
					if nextTag <= #s.tags then
						client.focus:move_to_tag(s.tags[nextTag])
						awful.tag.viewnext()
					end
				end
			end
		end,
	}),
	--
	-- Other Keybindings
	--
	Bind({
		group = "Other",
		description = "Screenshot selection mode",
		modifiers = { user.ModKey, user.ShiftKey },
		key = "s",
		on_press = function()
			bash.run(user.LocalBin .. "/screenshot --sel")
		end,
	}),
	Bind({
		group = "Other",
		description = "Screenshot all mode",
		modifiers = { user.ModKey, user.ShiftKey },
		key = "a",
		on_press = function()
			bash.run(user.LocalBin .. "/screenshot --all")
		end,
	}),
	Bind({
		group = "Other",
		description = "Open clipboard",
		modifiers = { user.ModKey },
		key = "v",
		on_press = function()
			bash.run("copyq show")
		end,
	}),
})

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		Bind({
			group = "Client",
			description = "Close",
			modifiers = { user.ModKey },
			key = "w",
			on_press = function(c)
				c:kill()
			end,
		}),
		Bind({
			group = "Client",
			description = "Toggle floating",
			modifiers = { user.ModKey, user.ShiftKey },
			key = "c",
			on_press = awful.client.floating.toggle,
		}),
	})
end)
