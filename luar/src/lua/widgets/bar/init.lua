local QSettingsPanelButton = require('lua.widgets.qsettings').QSettingsPanelButton
local Recorder = require('lua.services.recorder')
local Hyprland = astal.require('AstalHyprland')
local Tray = astal.require('AstalTray')
local Wp = astal.require('AstalWp')
local Icons = require('lua.widgets.icons')
local Varmap = require('lua.utils.varmap')
local json = require('lua.utils.json')
local lookup_icon = require('lua.utils.lookup_icon')
local settings = require('lua.utils.settings')

local clock_format = settings('bar-clock-format', 's')
local clock_interval = settings('bar-clock-interval', 'u')

local function RecordButton()
    local rec = Recorder.get_default()

    return Widget.Button {
        on_clicked = function(self)
            if not rec.recording then
                rec:start()
            else
                rec:stop()
            end

            self:toggle_css_class('highlight', not rec.recording)
        end,
        Widget.Box {
            css_classes = { 'gap-2' },
            Widget.Image {
                icon_name = 'media-record-symbolic',
            },
            Widget.Label {
                label = bind(rec, 'recording'):as(function(recording)
                    return recording and 'Recording' or 'Record'
                end),
            },
        },
    }
end

local function Clock()
    local time = Variable.new(os.date(clock_format:get())):poll(clock_interval:get(), function()
        return os.date(clock_format:get())
    end)

    return Widget.Label {
        css_classes = { 'heading' },
        label = bind(time),
        on_destroy = function()
            time:drop()
        end,
    }
end

local function Systray()
    local tray = Tray.get_default()
    local items = Varmap.new()

    local new = function(id)
        local item = tray:get_item(id)

        return Widget.MenuButton {
            css_classes = { 'flat' },
            setup = function(self)
                items:set(id, self)
            end,
            Widget.PopoverMenu {
                visible = false,
                menu_model = bind(item, 'menu-model'),
                action_group = bind(item, 'action-group'):as(function(value)
                    return { 'dbusmenu', value }
                end),
            },
            Widget.Image {
                gicon = bind(item, 'gicon'),
            },
        }
    end

    return Widget.MenuButton {
        icon_name = 'pan-down-symbolic',
        css_classes = { 'flat' },
        visible = bind(items):as(function(value)
            return #value > 0
        end),
        setup = function(self)
            -- stylua: ignore start
            self:hook(tray, 'item-added', function(_, id) new(id) end)
            self:hook(tray, 'item-removed', function(_, id) items:delete(id) end)
            self:hook(self.popover, 'notify::visible', function(_, visible)
                self.icon_name = visible and 'pan-up-symbolic' or 'pan-down-symbolic'
            end)
            -- stylua: ignore end
        end,
        ---@param self Gtk.MenuButton | Astalified4
        on_button_released = function(self, button)
            if button == Gdk.BUTTON_PRIMARY then self:popup() end
        end,
        Widget.Popover {
            visible = false,
            Widget.Box {
                css_classes = { 'gap-1' },
                bind(items),
            },
        },
    }
end

local function KbdLayout()
    local hypr = Hyprland.get_default()

    if not hypr then return end

    ---@async
    local get_layout = await(function()
        local devices = json.decode(hypr:async_message('j/devices'))

        if not devices then return end

        return table.find(devices.keyboards, function(kb)
            return kb.main
        end)
    end)

    local kbd = Variable.new(get_layout()):observe(hypr, 'keyboard-layout', get_layout)

    return Widget.Button {
        css_classes = { 'flat' },
        halign = 'CENTER',
        on_clicked = async(function()
            hypr:async_message(string.format('switchxkblayout %s next', kbd:get().name))
        end),
        on_button_released = async(function(_, button)
            if button == Gdk.BUTTON_SECONDARY then
                hypr:async_message(string.format('switchxkblayout %s prev', kbd:get().name))
            end
        end),
        Widget.Label {
            label = bind(kbd)
                :as(function(_kbd)
                    return _kbd.active_keymap
                end)
                :as(function(kmap)
                    return string.sub(kmap, 1, 2)
                end)
                :as(string.lower),
        },
    }
end

---@param args { display_icon?: boolean }
local function FocusedClient(args)
    local hypr = Hyprland.get_default()

    if not hypr then return end

    local client = Variable.new():observe(hypr, 'event', function()
        return hypr.focused_client
    end)

    return {
        Widget.Box {
            css_classes = { 'gap-3' },
            visible = bind(client),
            on_destroy = function()
                client:drop()
            end,

            args.display_icon and Widget.Image {
                icon_name = bind(client):as(function(c)
                    return c and c.initial_class or 'application-x-executable'
                end),
            },
            Widget.Label {
                css_classes = { 'heading' },
                label = bind(client)
                    :as(function(c)
                        return c and c.initial_class
                    end)
                    :as(tostring)
                    :as(string.title),
            },
        },
        Widget.Box {
            visible = bind(client):as(function(c)
                return not c
            end),
            Widget.Label {
                css_classes = { 'heading' },
                label = bind(hypr, 'focused-workspace'):as(function(wp)
                    return wp or { id = 0 }
                end):as(function(wp)
                    return string.format('Desktop %d', wp.id)
                end),
            },
        },
    }
end

local function PrivacyIndicators()
    local wp = Wp.get_default()

    ---@param args { icon_name: string, object: AstalWp.Audio | AstalWp.Video, type: 'recorders'|'streams' }
    local Indicator = function(args)
        local recorders = bind(args.object, args.type)

        return Widget.MenuButton {
            icon_name = args.icon_name,
            css_classes = { 'flat' },
            visible = recorders:as(function(array)
                return #array > 0
            end),
            Widget.Popover {
                visible = false,
                Widget.Box {
                    vertical = true,
                    Widget.Label { label = 'wea' },
                    recorders:as(function(array)
                        return table.map(array, function(stream)
                            local node_name = stream:get_pw_property('node.name')
                            local binary = stream:get_pw_property('application.process.binary')

                            return Widget.Box {
                                css_classes = { 'gap-2' },
                                Widget.Image { icon_name = lookup_icon(node_name, binary) },
                                Widget.Label { label = node_name },
                            }
                        end)
                    end),
                },
            },
        }
    end

    return {
        Indicator {
            icon_name = 'screen-shared-symbolic',
            object = wp.video,
            type = 'recorders',
        },
        Indicator {
            icon_name = 'audio-input-microphone-symbolic',
            object = wp.audio,
            type = 'recorders',
        },
    }
end

---@param args { gdkmonitor: Gdk.Monitor, anchor: ('TOP' | 'RIGHT' | 'LEFT' | 'BOTTOM' )[] }
return function(args)
    return Widget.Window {
        gdkmonitor = args.gdkmonitor,
        name = string.format('bar-%s', args.gdkmonitor.connector),
        namespace = 'astal-bar',
        css_classes = { 'bar', 'bg', 'px-3', 'py-1' },
        application = App,
        exclusivity = 'EXCLUSIVE',
        anchor = { 'LEFT', 'RIGHT', 'TOP' },

        Widget.CenterBox {
            Widget.Box {
                FocusedClient {
                    monitor_name = args.gdkmonitor.connector,
                    display_icon = true,
                },
            },

            Widget.Box {
                Clock(),
            },

            Widget.Box {
                -- css_classes = { 'gap-1' },

                Systray(),

                -- RecordButton(),

                KbdLayout(),

                QSettingsPanelButton {

                    Icons.WiFi {
                        show_when_powered = true,
                    },
                    Icons.Bluetooth {
                        show_when_powered = true,
                    },
                    Icons.Volume {},
                    Icons.Microphone {
                        show_when_muted = true,
                    },
                    Icons.NotifIcon {
                        show_when_dnd = true,
                    },
                    Icons.Battery {
                        display_percentage = true,
                    },
                },
                PrivacyIndicators {},
            },
        },
    }
end
