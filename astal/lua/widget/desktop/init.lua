local Hyprland = astal.require("AstalHyprland")

local cache_dir = GLib.getenv("XDG_CACHE_HOME") .. "/astal"
local wall_file = cache_dir .. "/wallpaper"
local desktop_wall = Variable("")

local request_wall = function(callback)
	return GlobalBus:call(
		"org.freedesktop.portal.Desktop",
		"/org/freedesktop/portal/desktop",
		"org.freedesktop.portal.FileChooser",
		"OpenFile",
		GLib.Variant("(ssa{sv})", {
			"",
			"Select Image",
			{
				accept_label = GLib.Variant("s", "Set"),
				filters = GLib.Variant("a(sa(us))", {
					{
						"Images",
						{
							{ 0, "*.jpg" },
							{ 0, "*.jpeg" },
							{ 0, "*.png" },
							{ 0, "*.svg" },
						},
					},
				}),
			},
		}),
		nil,
		Gio.DBusCallFlags.NONE,
		-1,
		nil,
		function(_, task)
			local result = GlobalBus:call_finish(task)
			if result then
				local bytes = result:get_data_as_bytes()
				local response_path = bytes:get_data()
				local subs_id

				subs_id = GlobalBus:signal_subscribe(
					nil,
					"org.freedesktop.portal.Request",
					"Response",
					response_path,
					nil,
					Gio.DBusSignalFlags.NONE,
					function(_, sender_name, object_path, interface_name, signal_name, parameters)
						GlobalBus:signal_unsubscribe(subs_id)
						subs_id = nil
						local response = parameters.value[1]

						if response == 0 then
							local uris = parameters.value[2].uris
							local uri = uris.value[1]
							callback(uri)
						end
					end
				)
			end
		end
	)
end

local desktop_menu = function(hypr)
	return Widget.GtkMenu({
		class_name = "desktop-menu",
		Widget.GtkMenuItem({
			label = "Web browser",
			on_activate = function()
				return hypr:message_async("dispatch exec 'firefox-nightly'")
			end,
		}),
		Widget.GtkMenuItem({
			label = "File manager",
			on_activate = function()
				return hypr:message_async("dispatch exec 'nautilus'")
			end,
		}),
		Widget.GtkSeparatorMenuItem(),
		Widget.GtkMenuItem({
			label = "Wallpaper",
			on_activate = function()
				return request_wall(function(filename)
					desktop_wall:set(filename)
					astal.write_file_async(wall_file, filename)
				end)
			end,
		}),
		Widget.GtkMenuItem({
			label = "Color picker",
			on_activate = function()
				return hypr:message_async("dispatch exec 'colorpicker'")
			end,
		}),
		Widget.GtkMenuItem({
			Widget.Box({
				Widget.Label({ label = "Screenshot" }),
				Widget.Icon({
					icon = "right-symbolic",
					class_name = "icon",
					valign = "CENTER",
					halign = "END",
					hexpand = true,
				}),
			}),
			submenu = Widget.GtkMenu({
				class_name = "desktop-menu",
				Widget.GtkMenuItem({
					label = "Select window",
					on_activate = function()
						return hypr:message_async("dispatch exec 'screenshot --win'")
					end,
				}),
				Widget.GtkMenuItem({
					label = "Select region",
					on_activate = function()
						return hypr:message_async("dispatch exec 'screenshot --sel'")
					end,
				}),
				Widget.GtkMenuItem({
					label = "All screen",
					on_activate = function()
						return hypr:message_async("dispatch exec 'screenshot --all'")
					end,
				}),
			}),
		}),
		Widget.GtkMenuItem({
			label = "Edit config",
			on_activate = function()
				hypr:message_async("dispatch exec 'zeditor $HOME/.config/astal'")
			end,
		}),
		Widget.GtkSeparatorMenuItem(),
		Widget.GtkMenuItem({
			label = "Open in BlackBox",
			on_activate = function()
				hypr:message_async("dispatch exec 'blackbox'")
			end,
		}),
		Widget.GtkSeparatorMenuItem(),
		Widget.GtkMenuItem({
			Widget.Box({
				Widget.Label({ label = "Exit" }),
				Widget.Icon({
					icon = "right-symbolic",
					class_name = "icon",
					valign = "CENTER",
					halign = "END",
					hexpand = true,
				}),
			}),
			submenu = Widget.GtkMenu({
				class_name = "desktop-menu",
				Widget.GtkMenuItem({ label = "Reboot" }),
				Widget.GtkMenuItem({ label = "Suspend" }),
				Widget.GtkMenuItem({ label = "Hibernate" }),
				Widget.GtkMenuItem({ label = "Shutdown" }),
			}),
		}),
	})
end

local is_image = function(filename)
	if GLib.file_test(filename, "EXISTS") then
		local img_ext = { ".png", ".jpg", ".jpeg", ".svg" }

		local filename_lower = string.lower(filename)

		for _, ext in ipairs(img_ext) do
			if filename_lower:sub(-#ext) == ext then
				return true
			end
		end
	end
	return false
end

return function(gdkmonitor)
	local windowname = string.format("desktop-%d", gdkmonitor.display:get_n_monitors())

	local hypr = Hyprland.get_default()
	local new_desktop_menu = desktop_menu(hypr)

	if not GLib.file_test(wall_file, "EXISTS") then
		astal.write_file_async(wall_file, "")
	else
		astal.read_file_async(wall_file, function(content)
			desktop_wall:set(content)
		end)
	end

	return Widget.Window({
		gdkmonitor = gdkmonitor,
		namespace = windowname,
		anchor = Astal.WindowAnchor.TOP
			+ Astal.WindowAnchor.LEFT
			+ Astal.WindowAnchor.RIGHT
			+ Astal.WindowAnchor.BOTTOM,
		layer = "BACKGROUND",
		name = windowname,
		exclusivity = "IGNORE",
		keymode = "EXCLUSIVE",
		class_name = "desktop",
		Widget.EventBox({
			setup = function(self)
				self:drag_dest_set(Gtk.DestDefaults.ALL, {}, Gdk.DragAction.COPY)
				self:drag_dest_add_text_targets()
			end,
			on_drag_data_received = function(_, _, _, _, data)
				local filename = data:get_text()
				if filename and is_image(filename) then
					desktop_wall:set(filename)
					astal.write_file_async(wall_file, filename)
				end
			end,
			on_button_press_event = function(_, event)
				if event.button == Gdk.BUTTON_SECONDARY then
					return new_desktop_menu:popup_at_pointer(event)
				end
			end,
			Widget.Box({
				class_name = "desktop-box",
				css = desktop_wall():as(function(v)
					return string.format("background-image: url('%s');", v)
				end),
				Widget.Label({
					valign = "END",
					halign = "CENTER",
					hexpand = true,
					vexpand = true,
					setup = function(self)
						hypr:message_async("splash", function(_, task)
							self.label = hypr:message_finish(task)
						end)
					end,
				}),
			}),
		}),
	})
end
