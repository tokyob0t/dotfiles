local settings = require('lua.utils.settings')
local async_exec = require('astal.process').async_exec

local history, set_history = settings('clipboard-history', 'a(ts)')

local wl_copy = function(...)
    return async_exec { 'wl-copy', ... }
end

---@type function
local show_toast

---@param args { title: string, subtitle: string, on_copied: function, on_deleted: function }
local function ClipboardItem(args)
    -- local is_image = GLib.uri_is_valid(args.title, 'ENCODED_PATH')
    --     and GLib.file_test(GLib.uri_parse(args.title, 'ENCODED_PATH'):get_path(), 'EXISTS')

    -- if is_image then
    --     return Widget.ListBoxRow {
    --         Widget.Overlay {
    --             Widget.Picture {
    --                 file = Gio.File.new_for_uri(args.title),
    --                 height_request = 200,
    --             },
    --             Widget.Box {
    --                 halign = 'END',
    --                 valign = 'CENTER',
    --                 Widget.Button {
    --                     icon_name = 'edit-copy-symbolic',
    --                     css_classes = { 'flat', 'transition-opacity' },
    --                     valign = 'CENTER',
    --                     on_clicked = args.on_copied,
    --                 },
    --                 Widget.Button {
    --                     icon_name = 'user-trash-symbolic',
    --                     css_classes = { 'flat', 'transition-opacity' },
    --                     valign = 'CENTER',
    --                     on_clicked = args.on_deleted,
    --                     on_hover_enter = function(self) self:add_css_class('destructive-action') end,
    --                     on_hover_leave = function(self) self:remove_css_class('destructive-action') end,
    --                 },
    --             },
    --         },
    --     }
    -- end

    return Widget.ActionRow {
        use_markup = false,
        activatable = true,
        title_lines = 3,
        subtitle_lines = 1,
        suffixes = {
            Widget.Button {
                icon_name = 'edit-copy-symbolic',
                css_classes = { 'flat', 'transition-opacity' },
                valign = 'CENTER',
                on_clicked = args.on_copied,
            },
            Widget.Button {
                icon_name = 'user-trash-symbolic',
                css_classes = { 'flat', 'transition-opacity' },
                valign = 'CENTER',
                on_clicked = args.on_deleted,
            },
        },
        setup = function(self)
            self.title, self.subtitle = args.title, args.subtitle
        end,
    }
end

---@type Gtk.SearchBar | Astalified4 | { child: Gtk.SearchEntry }
local search_bar = Widget.SearchBar {
    Widget.SearchEntry {
        hexpand = true,
        tooltip_text = 'Type to Search...',
    },
}

local clipboard = Widget.ApplicationWindow {
    application = App,
    resizable = false,
    title = 'Clipboard',
    name = 'clipboard',
    visible = false,
    default_width = 400,
    default_height = 500,
    hide_on_close = true,
    icon_name = 'application-x-executable',
    setup = function(self)
        search_bar.key_capture_widget = self
    end,
    on_hide = function()
        search_bar.child.text, search_bar.search_mode_enabled = '', false
    end,
    Widget.ToolbarView {
        Widget.HeaderBar {
            Widget.ToggleButton {
                css_classes = { 'flat' },
                icon_name = 'search-symbolic',
                setup = function(self)
                    -- stylua: ignore start
                    local binding =
                        self:bind_property( 'active', search_bar, 'search-mode-enabled', { 'BIDIRECTIONAL' })
                    -- stylua: ignore end

                    self.on_destroy = function()
                        binding:unbind()
                    end
                end,
                on_notify_active = function(self, active)
                    self:toggle_css_class('highlight', active)
                end,
            },
        },
        search_bar,
        Widget.Overlay {
            Widget.StatusPage {
                icon_name = 'clipboard-symbolic',
                title = 'Clipboard Empty',
                description = 'Copy something to see it here.',
                visible = history:as(function(items)
                    return #items == 0
                end),
            },
            Widget.ToastOverlay {
                setup = function(self)
                    show_toast = function(text)
                        self:dismiss_all()
                        self:add_toast(Adw.Toast { title = text, timeout = 3 })
                    end
                end,

                Widget.ScrolledWindow {
                    hscrollbar_policy = 'NEVER',
                    visible = history:as(function(items)
                        return #items > 0
                    end),
                    Widget.ListBox {
                        selection_mode = 'NONE',
                        css_classes = { 'boxed-list-separate', 'm-2' },
                        setup = function(self)
                            local clipboard_items = {}

                            local on_removed = function(timestamp)
                                local w = clipboard_items[timestamp]

                                if w then
                                    self:remove(w)
                                    clipboard_items[timestamp] = nil
                                end
                            end

                            local on_added = function(timestamp, data)
                                clipboard_items[timestamp] = ClipboardItem {
                                    title = data,
                                    subtitle = tostring(os.date('%H:%M', timestamp)),
                                    on_copied = async(function()
                                        show_toast('Copied to clipboard')
                                        wl_copy('--type', 'text/plain;charset=utf-8', data)
                                    end),
                                    on_deleted = function()
                                        show_toast('Removed from Clipboard')
                                        on_removed(timestamp)
                                        set_history(table.filter(history:get(), function(tuple)
                                            return tuple[1] ~= timestamp
                                        end))
                                    end,
                                }

                                self:prepend(clipboard_items[timestamp])
                            end

                            local history_cache = history:get()

                            table.sort(history_cache, function(a, b)
                                return a[1] < b[1]
                            end)

                            for _, tuple in ipairs(history_cache) do
                                on_added(table.unpack(tuple))
                            end

                            self.on_destroy = history:subscribe(function(_history)
                                local old_len = #history_cache
                                local new_len = #_history

                                if new_len > old_len then
                                    for _, tuple in ipairs(_history) do
                                        local added = not table.any(history_cache, function(t)
                                            return t[2] == tuple[2]
                                        end)
                                        if added then on_added(table.unpack(tuple)) end
                                    end
                                elseif new_len < old_len then
                                    for _, tuple in ipairs(_history) do
                                        local removed = not table.any(history_cache, function(t)
                                            return t[2] == tuple[2]
                                        end)
                                        if removed then return on_removed(tuple[2]) end
                                    end
                                end

                                history_cache = _history
                            end)
                        end,
                    },
                },
            },
        },
    },
}
