astal = require("astal")
GLib = astal.GLib
Gtk = astal.Gtk
Gdk = astal.Gdk
Gio = astal.Gio

Astal = astal.Astal
Widget = astal.Widget
Widget.GtkRevealer = Widget.astalify(Gtk.Revealer)
Widget.GtkScrolledWindow = Widget.astalify(Gtk.ScrolledWindow)
Widget.GtkMenu = Widget.astalify(Gtk.Menu)
Widget.GtkMenuItem = Widget.astalify(Gtk.MenuItem)
Widget.GtkEventBox = Widget.astalify(Gtk.EventBox)
Widget.GtkButton = Widget.astalify(Gtk.Button)
Widget.GtkSeparatorMenuItem = Widget.astalify(Gtk.SeparatorMenuItem)
Widget.GtkWindow = Widget.astalify(Gtk.Window)

bind = astal.bind

Variable = astal.Variable
GlobalBus = nil

Gio.bus_get(Gio.BusType.SESSION, nil, function(_, task)
	GlobalBus = Gio.bus_get_finish(task)
end)

---https://stackoverflow.com/a/65047878
switch = function(element)
	local Table = {
		["Value"] = element,
		["DefaultFunction"] = nil,
		["Functions"] = {},
	}

	Table.case = function(...)
		local args = { ... }
		assert(type(args[#args]) == "function")
		local callback = table.remove(args, #args)
		for _, arg in ipairs(args) do
			Table.Functions[arg] = callback
		end
		return Table
	end

	Table.default = function(callback)
		Table.DefaultFunction = callback
		return Table
	end

	Table.process = function()
		local Case = Table.Functions[Table.Value]
		if Case then
			return Case(Table.Value)
		elseif Table.DefaultFunction then
			return Table.DefaultFunction()
		end
	end

	return Table
end

---@generic T, F
---@param condition boolean
---@param if_true T
---@param if_false F
---@return T | F
ternary = function(condition, if_true, if_false)
	if condition then
		return if_true
	else
		return if_false
	end
end

local tb_override = function(target, source)
	for key, value in pairs(source) do
		target[key] = value
	end
	return target
end

lookup_icon = function(args)
	if type(args) == "string" then
		return lookup_icon({ icon_name = args })
	elseif type(args) == "table" then
		if #args >= 1 and not args.icon_name then
			local path = nil
			for _, value in ipairs(args) do
				path = lookup_icon(value)
				if path then
					return path
				end
			end
			return
		elseif args.icon_name and type(args.icon_name) == "table" then
			local path
			for _, value in ipairs(args.icon_name) do
				path = lookup_icon({
					icon_name = value,
					size = args.size,
					path = args.path,
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

	args = tb_override({
		icon_name = "",
		size = 128,
		path = true,
	}, args)

	local theme = Gtk.IconTheme.get_default()
	local icon_info, path

	for _, name in ipairs({
		args.icon_name,
		args.icon_name:lower(),
		args.icon_name:upper(),
	}) do
		icon_info = theme:lookup_icon(name, args.size, Gtk.IconLookupFlags.USE_BUILTIN)

		if icon_info then
			path = icon_info:get_filename()

			if path then
				if args.path then
					return string.match(path, ".*/(.-)%.svg")
				else
					return icon_info:load_icon()
				end
			end
		end
	end
end

-- local widget_keybinds = {}

-- local keybind = function(self, modifiers, key, callback)
-- 	local keyval
-- 	if key == "Escape" then
-- 		keyval = Gdk.KEY_Escape
-- 	else
-- 		keyval = Gdk["KEY_" .. key]
-- 	end
-- 	table.insert(widget_keybinds, {
-- 		modifiers = modifiers,
-- 		key = keyval,
-- 		callback = callback,
-- 	})
-- end

-- local handle_keypress_event = function(self, event)
-- 	local keyval = event.keyval
-- 	local state = event.state

-- 	for _, bind in ipairs(widget_keybinds) do
-- 		local all_modifiers_pressed = true

-- 		for _, mod in ipairs(bind.modifiers) do
-- 			if not state[mod .. "_MASK"] then
-- 				all_modifiers_pressed = false
-- 				break
-- 			end
-- 		end

-- 		if all_modifiers_pressed and bind.key == keyval then
-- 			bind.callback(self, event)
-- 			return true
-- 		end
-- 	end
-- end

rem = function(px)
	return px / 16
end
