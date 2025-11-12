local Btns = require('lua.widgets.qsettings.buttons')
local Network = astal.require('AstalNetwork')
local Bluetooth = astal.require('AstalBluetooth')
local Icons = require('lua.widgets.icons')
local Notifd = astal.require('AstalNotifd')
local Caffeine = require('lua.services.caffeine')

local variant = require('lua.utils.variant')

local ToggleButton, SimpleButton = Btns.ToggleButton, Btns.SimpleButton

local gnome = Gio.Settings {
    schema_id = 'org.gnome.desktop.interface',
}

local dark_mode = bind {
    get = function()
        return variant.decode(gnome:get_value('color-scheme'))
    end,
    subscribe = function(self, callback)
        local id = gnome.on_changed:connect(function(_, _key)
            if _key == 'color-scheme' then callback(self:get()) end
        end)

        return function()
            GObject.signal_handler_disconnect(gnome, id)
        end
    end,
}
local set_dark_mode = function(value)
    if value ~= dark_mode:get() then gnome:set_value('color-scheme', GLib.Variant('s', value)) end
end

local visible_tag = Variable.new('default')

---@param args { tag: string, title: string, suffix: Gtk.Widget?, hide_header: boolean }
local function Page(args)
    return Widget.NavigationPage {
        tag = args.tag,
        title = args.title,
        Widget.ToolbarView {
            not args.hide_header and Widget.HeaderBar {
                show_end_title_buttons = false,
                end_widget = args.suffix and Widget.Box {
                    valign = 'CENTER',
                    args.suffix,
                },
            },
            table.unpack(args),
        },
    }
end

---@type table<integer, Astal.Window | Astalified4 >
local panel_instances = {}

local module = {}

---@param args Gtk.Widget[]
function module.QSettingsPanelButton(args)
    return Widget.Button {
        css_classes = { 'flat' },
        on_clicked = function(self)
            local visible = not table.find(panel_instances, function(win)
                return win.visible
            end)

            self:toggle_css_class('highlight', visible)

            for _, win in ipairs(panel_instances) do
                win.visible = visible
            end
        end,
        Widget.Box {
            css_classes = { 'gap-1' },
            table.unpack(args),
        },
    }
end

---@param args { gdkmonitor: Gdk.Monitor }
function module.QSettingsPanel(args)
    return Widget.Window {
        gdkmonitor = args.gdkmonitor,
        visible = false,
        namespace = 'astal-qsettings',
        css_classes = { 'qsettings', 'bg', 'mt-2', 'mr-2' },
        anchor = { 'TOP', 'RIGHT' },
        setup = function(self)
            table.insert(panel_instances, self)
        end,
        Widget.NavigationView {
            setup = function(self)
                self:hook(visible_tag, function(_, tag)
                    self:push_by_tag(tag)
                end)
            end,
            Page {
                tag = 'default',
                title = 'default',
                hide_header = true,
                Widget.Grid {
                    css_classes = { 'm-2', 'gap-2' },
                    column_homogeneous = true,
                    setup = function(self)
                        -- self:attach(Header(), 0, 0, 3, 1)

                        local caffeine = Caffeine.get_default()
                        local notifd = Notifd.get_default()

                        local flags = { 'BIDIRECTIONAL', 'SYNC_CREATE' }

                        ToggleButton {
                            grid = self,
                            column = 1,
                            row = 1,
                            width = 2,
                            icon_name = 'network-wireless-symbolic',
                            label = 'Wi-Fi',
                            setup = function(this)
                                local net = Network.get_default()
                                local wifi = net.wifi

                                if wifi then
                                    local binding =
                                        wifi:bind_property('enabled', this, 'active', flags)
                                    this.on_destroy = function()
                                        binding:unbind()
                                    end
                                end
                            end,
                        }

                        ToggleButton {
                            grid = self,
                            column = 3,
                            row = 1,
                            width = 2,
                            icon_name = 'bluetooth-symbolic',
                            label = 'Bluetooth',
                            setup = function(this)
                                local bt = Bluetooth.get_default()
                                local adapter = bt.adapter

                                if adapter then
                                    local binding =
                                        adapter:bind_property('powered', this, 'active', flags)
                                    this.on_destroy = function()
                                        binding:unbind()
                                    end
                                end
                            end,
                        }

                        ToggleButton {
                            grid = self,
                            column = 5,
                            row = 1,
                            width = 2,
                            icon = Icons.NotifIcon {},
                            label = bind(notifd, 'dont-disturb'):as(function(dnd)
                                return dnd and 'Silent' or 'Noisy'
                            end),
                            setup = function(this)
                                local binding =
                                    notifd:bind_property('dont-disturb', this, 'active', flags)

                                this.on_destroy = function()
                                    binding:unbind()
                                end
                            end,
                        }

                        -- ToggleButton {
                        --     grid = self,
                        --     column = 1,
                        --     row = 2,
                        --     width = 2,
                        --     icon_name = 'moon-outline-symbolic',
                        --     label = 'Caffeine',
                        --     setup = function(this)
                        --         local binding =
                        --             caffeine:bind_property('active', this, 'active', flags)

                        --         this.on_destroy = function()
                        --             binding:unbind()
                        --         end
                        --     end,
                        -- }

                        ToggleButton {
                            grid = self,
                            column = 1,
                            row = 2,
                            width = 2,
                            icon_name = 'moon-outline-symbolic',
                            label = 'Dark Mode',
                            setup = function(this)
                                this.active = dark_mode:get() == 'prefer-dark'
                                ---@param value 'default' | 'prefer-dark' | 'prefer-light'
                                this.on_destroy = dark_mode:subscribe(function(value)
                                    if value == 'prefer-dark' then this.active = true end
                                end)

                                this:hook(this, 'toggled', function()
                                    if this.active then return set_dark_mode('prefer-dark') end
                                    set_dark_mode('prefer-light')
                                end)
                            end,
                        }
                    end,
                },
            },
            Page {
                tag = 'wifi',
                title = 'Wi-Fi',
            },
        },
    }
end

return module
