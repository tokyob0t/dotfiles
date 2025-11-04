astal = require('astal')
App = require('astal.gtk4.app')
Widget = require('astal.gtk4.widget')

Variable, bind = astal.Variable, astal.bind
async, await = astal.async, astal.await

GLib = astal.require('GLib')
Gdk = astal.require('Gdk')
Gtk = astal.require('Gtk')
Gio = astal.require('Gio')
GioUnix = astal.require('GioUnix')
Adw = astal.require('Adw')
GObject = astal.require('GObject')

local astalify = require('astal.gtk4.astalify')

Widget.Avatar = astalify(Adw.Avatar)

Widget.ListBox = astalify(Gtk.ListBox)

Widget.ListBoxRow = astalify(Gtk.ListBoxRow, {
    set_children = function(self, children) self.child = children[1] or Gtk.Box {} end,
})

Widget.ScrolledWindow = astalify(Gtk.ScrolledWindow, {})

---@type Adw.AlertDialog | { responses: { id: string, label: string, appearance: Adw.ResponseAppearance? }[] }
local AlertDialog = Adw.AlertDialog

---@diagnostic disable-next-line
AlertDialog._attribute.responses = {
    set = function(self, responses)
        for _, value in ipairs(responses) do
            self:add_response(value.id, value.label)
            if value.appearance then self:set_response_appearance(value.id, value.appearance) end
        end
    end,
}
Widget.AlertDialog = astalify(AlertDialog)

Widget.SearchEntry = astalify(Gtk.SearchEntry)

Widget.NavigationPage = astalify(Adw.NavigationPage, {
    set_children = function(self, children) self.child = children[1] or Gtk.Box {} end,
    get_children = function(self) return { self.child } end,
})
Widget.NavigationView = astalify(Adw.NavigationView, {
    set_children = function(self, children)
        for _, ch in ipairs(children) do
            self:add(ch)
        end
    end,
    get_children = function() return {} end,
})

Widget.Clamp = astalify(Adw.Clamp)

Widget.Overlay = astalify(Gtk.Overlay, {
    set_children = function(self, children)
        self.child = table.remove(children, 1) or Gtk.Box {}

        for _, ch in ipairs(children) do
            self:add_overlay(ch)
        end
    end,
})

Widget.Picture = astalify(Gtk.Picture)

Widget.FileChooserDialog = astalify(Gtk.FileChooserDialog)
Widget.Spinner = astalify(Adw.Spinner)
Widget.PasswordEntry = astalify(Gtk.PasswordEntry)

Widget.GtkWindow = astalify(Gtk.Window, {
    set_children = function(self, children) self.child = children[1] or Gtk.Box {} end,
    get_children = function(self) return { self.child } end,
})

Widget.Separator = astalify(Gtk.Separator)

Widget.Stack = astalify(Gtk.Stack, {
    set_children = function(self, children)
        for _, ch in ipairs(children) do
            if ch.name then
                self:add_named(ch, ch.name)
            else
                self:add_child(ch)
            end
        end
    end,
})

Widget.ToggleButton = astalify(Gtk.ToggleButton)

Widget.PopoverMenu = astalify(Gtk.PopoverMenu)
Widget.Popover = astalify(Gtk.Popover)

Widget.ApplicationWindow = astalify(Adw.ApplicationWindow, {
    set_children = function(self, children) self.content = children[1] or Gtk.Box {} end,
    get_children = function(self) return { self.content } end,
})

Widget.ToolbarView = astalify(Adw.ToolbarView, {
    set_children = function(self, children)
        if Adw.HeaderBar:is_type_of(children[1]) then
            self:add_top_bar(table.remove(children, 1))
        end

        if Gtk.SearchBar:is_type_of(children[1]) then
            self:add_top_bar(table.remove(children, 1))
        end

        self.content = table.remove(children, 1)

        if Gtk.SearchBar:is_type_of(children[1]) then
            self:add_bottom_bar(table.remove(children, 1))
        end

        if Adw.HeaderBar:is_type_of(children[1]) then
            self:add_bottom_bar(table.remove(children, 1))
        end
    end,
    get_children = function(self) return { self.content } end,
})

---@type Adw.HeaderBar | { start_widget: Gtk.Widget, end_widget: Gtk.Widget }
local HeaderBar = Adw.HeaderBar

HeaderBar._attribute.start_widget = {
    set = function(self, widget) self:pack_start(widget) end,
}

HeaderBar._attribute.end_widget = {
    set = function(self, widget) self:pack_end(widget) end,
}

Widget.HeaderBar = astalify(HeaderBar, {
    set_children = function(self, children)
        if children[1] then self.start_widget = table.remove(children, 1) end
        if children[1] then self:title_widget(table.remove(children, 1)) end
        if children[1] then self.end_widget = table.remove(children, 1) end
    end,
    get_children = function() return {} end,
})

Widget.StatusPage = astalify(Adw.StatusPage)
Widget.SearchBar = astalify(Gtk.SearchBar)

Widget.Grid = astalify(Gtk.Grid)

Widget.PreferencesGroup = astalify(Adw.PreferencesGroup, {
    set_children = function(self, children)
        table.iterate(children, function(ch) self:add(ch) end)
    end,
    get_children = function() return {} end,
})
Widget.PreferencesPage = astalify(Adw.PreferencesPage, {
    set_children = function(self, children)
        table.iterate(children, function(ch) self:add(ch) end)
    end,
    get_children = function() return {} end,
})

---@type Adw.ActionRow | { prefix: Gtk.Widget, suffix: Gtk.Widget, prefixes: Gtk.Widget[], suffixes: Gtk.Widget[] }
local ActionRow = Adw.ActionRow

---@diagnostic disable-next-line
ActionRow._attribute.prefix = {
    set = function(self, prefix) self:add_prefix(prefix) end,
}

ActionRow._attribute.prefixes = {
    set = function(self, prefixes)
        for _, value in ipairs(prefixes) do
            self:add_prefix(value)
        end
    end,
}

---@diagnostic disable-next-line
ActionRow._attribute.suffix = {
    set = function(self, suffix) self:add_suffix(suffix) end,
}

ActionRow._attribute.suffixes = {
    set = function(self, suffixes)
        for _, value in ipairs(suffixes) do
            self:add_suffix(value)
        end
    end,
}

Widget.ActionRow = astalify(ActionRow)

Widget.ToastOverlay = astalify(Adw.ToastOverlay)
