local settings = require('lua.utils.settings')
local search_delay = settings('launcher-search-delay', 'u')

---@type function, function, function, function
local hide, clear, focus, launch_first

local SearchBackends = require('lua.widgets.launcher.backends')

local filter, childrens, icons = SearchBackends()

local launcher = Widget.Window {
    name = 'launcher',
    application = App,
    visible = false,
    namespace = 'astal-launcher',
    keymode = 'EXCLUSIVE',
    css_classes = { 'transparent' },
    anchor = { 'TOP', 'BOTTOM' },
    setup = function(self)
        hide = function()
            self:hide()
        end
    end,
    on_show = function()
        focus()
    end,
    on_hide = function()
        clear()
    end,
    on_key_pressed = function(_, keyval)
        local ESC = keyval == Gdk.KEY_Escape

        if ESC then hide() end
    end,
    Widget.Box {
        vertical = true,
        valign = 'START',
        css_classes = { 'vertical', 'rounded-3xl', 'bg', 'p-2' },
        Widget.Box {
            Widget.SearchEntry {
                placeholder_text = 'Type to Search...',
                valign = 'START',
                hexpand = true,
                css_classes = { 'flat', 'm-2' },
                search_delay = search_delay,
                setup = function(self)
                    clear = function()
                        self.text = ''
                    end
                    focus = function()
                        self:grab_focus()
                    end
                end,
                on_search_changed = function(self)
                    filter(self.text)
                end,
                on_stop_search = function()
                    hide()
                end,
                on_activate = function()
                    launch_first()
                end,
            },
            icons,
        },
        Widget.Box {
            vertical = true,
            valign = 'START',
            ---@param self Gtk.Box | Astalified4 | { children: Gtk.Revealer[] }
            setup = function(self)
                launch_first = function()
                    ---@type Gtk.Revealer | { child: Gtk.Button }?
                    local found = table.find(self.children, function(ch)
                        return ch.child_revealed
                    end)

                    if found then found.child:activate() end
                end
            end,
            childrens,
        },
    },
}
