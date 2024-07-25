local lgi = require("lgi")
local Gio = lgi.require("Gio", "2.0")
local Gtk = lgi.require("Gtk", "3.0")
local cairo = lgi.require("cairo", "1.0")
local Rsvg = lgi.require("Rsvg", "2.0")

local my_table = require("utils.table")
local my_string = require("utils.str")

local UPowerGlib = lgi.require("UPowerGlib", "1.0")
local NM = lgi.require("NM", "1.0") -- ToDo
local Playerctl = lgi.require("Playerctl", "2.0")

---@type awful
local awful = require("awful")
local naughty = require("naughty")

local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi

Gtk.IconTheme.get_default():prepend_search_path(require("user").IconFolder)

local _Utils = {}
_Utils.Gtk = Gtk
_Utils.Gio = Gio
_Utils.UPowerGlib = UPowerGlib
_Utils.NM = NM
_Utils.Playerctl = Playerctl
_Utils.table = my_table
_Utils.string = my_string
_Utils.bash = require("utils.bash")
---@param number number
---@return number
_Utils.dpi = function(number)
	return dpi(number)
end

---@param args string | any | { message: string, title: string, timeout: integer, hover_timeout: integer, screen: integer | screen, position: "top_left" | "top_right" | "bottom_left" | "bottom_right" | "top_middle" | "bottom_middle" | "middle", ontop: boolean, height: integer, width: integer, font: string, icon: string, icon_size: integer, fg: string, bg: string, border_width: integer, border_color: string, shape: gears.shape, opacity: gears.opacity, margin: gears.margin, run: function, destroy: function, preset: table, replaces_id: integer, callback: function, actions: table, ignore_suspend: boolean }
_Utils.notify = function(args)
	if type(args) == "table" then
		require("naughty").notification(args)
	elseif type(args) == "string" then
		return require("naughty").notification({ message = args })
	else
		return require("naughty").notification({ message = tostring(args) })
	end
end

--- @param args {group: string?, description: string?, modifiers: table?, key: (string | "numrow" | "arrows" | "fkeys" | "numpad" )?, on_press: function?, on_release:function? }
--- @return table
_Utils.Bind = function(args)
	args = _Utils.table.override({
		group = "Generic text",
		description = "Generic description",
		modifiers = {},
		key = nil,
		on_press = function() end,
		on_release = function() end,
	}, args)

	if _Utils.table.contains({
		"numrow",
		"arrows",
		"fkeys",
		"numpad",
	}, args.key) then
		return awful.key({
			modifiers = args.modifiers,
			keygroup = args.key,
			description = args.description,
			group = args.group,
			on_press = args.on_press,
			on_release = args.on_release,
		})
	else
		return awful.key({
			modifiers = args.modifiers,
			key = args.key,
			description = args.description,
			group = args.group,
			on_press = args.on_press,
			on_release = args.on_release,
		})
	end
end

--- Get the layout based on its name.
--- @param name "tile" | "floating" | "tile_left" | "tile_bottom" | "tile_top" | "fair_vertical" | "fair_horitonzal" | "spiral" | "dwindle" | "max" | "fullscreen" | "magnifier" | "corner"
--- @return awful.layout
_Utils.GetLayout = function(name)
	local awful_layouts = {
		tile = awful.layout.suit.tile,
		floating = awful.layout.suit.floating,
		tile_left = awful.layout.suit.tile.left,
		tile_bottom = awful.layout.suit.tile.bottom,
		tile_top = awful.layout.suit.tile.top,
		fair_vertical = awful.layout.suit.fair,
		fair_horitonzal = awful.layout.suit.fair.horizontal,
		spiral = awful.layout.suit.spiral,
		dwindle = awful.layout.suit.spiral.dwindle,
		max = awful.layout.suit.max,
		fullscreen = awful.layout.suit.max.fullscreen,
		magnifier = awful.layout.suit.magnifier,
		corner = awful.layout.suit.corner.nw,
	}
	return awful_layouts[name]
end

--- Get the icon path for a specific layout.
--- @param name string
--- @return string
_Utils.LayoutIcon = function(name)
	return gears.filesystem.get_configuration_dir() .. "theme/layouts/" .. name .. ".png"
end

---@param condition boolean
---@param ifTrue any
---@param ifFalse any
---@return any
_Utils.t = function(condition, ifTrue, ifFalse)
	if condition then
		return ifTrue
	else
		return ifFalse
	end
end

---@param radius number
---@return function
_Utils.rrect = function(radius)
	return function(cr, width, height)
		return gears.shape.rounded_rect(cr, width, height, radius)
	end
end

---Fill non-transparent area of an image with a given color.
---@param image string
---@param new_color string
---@return surface | nil
_Utils.recolor_image = function(image, new_color, width, height)
	if type(image) == "string" then
		width = width or 16
		height = height or 16
		local handle = Rsvg.Handle.new_from_file(image)
		local dimensions = handle:get_dimensions()

		-- Create a new Cairo surface with the desired dimensions
		local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
		local cr = cairo.Context(surface)

		-- Scale the context to the desired size
		cr:scale(width / dimensions.width, height / dimensions.height)

		handle:render_cairo(cr)

		return gears.color.recolor_image(surface, new_color)
	else
		return gears.color.recolor_image(image, new_color)
	end
end

---@param width number
---@param height number
---@param surface surface
---@return surface
_Utils.resize_surface = function(width, height, surface)
	local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
	local cr = cairo.Context(out_surf)

	local orig_width = surface:get_width()
	local orig_height = surface:get_height()

	local scale_x = width / orig_width
	local scale_y = height / orig_height
	cr:scale(scale_x, scale_y)
	cr:set_source_surface(surface, 0, 0)
	cr.operator = cairo.Operator.SOURCE
	cr:paint()

	return out_surf
end

---@param radius  number
---@param surface surface
---@return surface
_Utils.round_surface = function(radius, surface)
	local width = surface:get_width()
	local height = surface:get_height()

	local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
	local cr = cairo.Context(out_surf)
	cr:arc(radius, radius, radius, math.pi, 3 * math.pi / 2)
	cr:arc(width - radius, radius, radius, 3 * math.pi / 2, 0)
	cr:arc(width - radius, height - radius, radius, 0, math.pi / 2)
	cr:arc(radius, height - radius, radius, math.pi / 2, math.pi)
	cr:close_path()

	cr:clip()

	cr:set_source_surface(surface, 0, 0)
	cr.operator = cairo.Operator.SOURCE
	cr:paint()

	return out_surf
end

---Looks up a named icon for a desired size and window scale
---@param args string | string[] | {icon_name : string | string[], size:  8 | 16 | 32 | 64 | 128 | 256 | 512 | number, path: boolean, recolor: string}
---@return string | surface | nil
_Utils.lookup_icon = function(args)
	if type(args) == "string" then
		return _Utils.lookup_icon({ icon_name = args })
	--elseif type(args) == "table" and #args >= 1 and not args.icon_name then
	--elseif type(args) == "table" and args.icon_name and type(args.icon_name) == "table" then
	elseif type(args) == "table" then
		if #args >= 1 and not args.icon_name then
			local path = nil
			for _, value in ipairs(args) do
				path = _Utils.lookup_icon(value)
				if path then
					return path
				end
			end
			return
		elseif args.icon_name and type(args.icon_name) == "table" then
			local path
			for _, value in ipairs(args.icon_name) do
				path = _Utils.lookup_icon({
					icon_name = value,
					size = args.size,
					path = args.path,
					recolor = args.recolor,
				})
				if path then
					return path
				end
			end
			return
		end
	end

	if not args or not args.icon_name then
		return
	end

	args = _Utils.table.override({
		icon_name = "",
		size = 128,
		path = true,
		recolor = nil,
	}, args)

	local theme = Gtk.IconTheme.get_default()
	local icon_info, path

	for _, name in ipairs({
		args.icon_name,
		args.icon_name:lower(),
		args.icon_name:upper(),
		_Utils.string.capitalize(args.icon_name),
	}) do
		icon_info = theme:lookup_icon(name, args.size, Gtk.IconLookupFlags.USE_BUILTIN)

		if not icon_info then
			goto continue
		end

		path = icon_info:get_filename()

		if not path then
			goto continue
		end

		if args.path then
			if args.recolor ~= nil then
				return _Utils.recolor_image(path, args.recolor, args.size, args.size)
			else
				return path
				--return gears.surface(Gio.FileIcon.new(Gio.File.new_for_path(path)))
			end
		else
			return icon_info
		end

		::continue::
	end
end

---@param object GObject.Object
---@return GearsObject_GObject
_Utils.gobject_to_gearsobject = function(object)
	---@type GearsObject_GObject
	local new_gobject = gears.object({})

	new_gobject._class = object
	new_gobject.set_class = function() end
	new_gobject.get_class = function(self)
		return self._class
	end

	new_gobject._class.on_notify = function(self, signal)
		return new_gobject:emit_signal("property::" .. signal:get_name(), self[signal:get_name()])
	end

	setmetatable(new_gobject, {
		__index = function(_, key)
			local method_value

			method_value = gears.object[key]

			if method_value then
				return method_value
			end

			method_value = new_gobject._class[key]

			if method_value then
				if type(method_value) == "userdata" then
					return function(self, ...)
						if self == new_gobject then
							return method_value(new_gobject._class, ...)
						else
							return method_value(self, ...)
						end
					end
				else
					return method_value
				end
			end
		end,
	})

	return new_gobject
end

---@param timeout number
---@param callback function
---@return gears.timer
_Utils.wait = function(timeout, callback)
	timeout = timeout or 1
	callback = callback or function() end

	return gears.timer({
		timeout = timeout,
		autostart = true,
		single_shot = true,
		callback = callback,
	})
end

return _Utils
