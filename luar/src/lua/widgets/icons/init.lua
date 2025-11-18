local Network = astal.require('AstalNetwork')
local Bluetooth = astal.require('AstalBluetooth')
local Wp = astal.require('AstalWp')
local Battery = astal.require('AstalBattery')
local Notifd = astal.require('AstalNotifd')

local module = {}

---@param args { show_when_powered: boolean }
function module.WiFi(args)
    local network = Network.get_default()

    ---@param wifi AstalNetwork.Wifi?
    return bind(network, 'wifi'):as(function(wifi)
        if not wifi then return end

        local visible

        if args.show_when_powered then visible = bind(wifi, 'enabled') end

        return Widget.Image {
            visible = visible,
            icon_name = bind(wifi, 'icon-name'),
            tooltip_text = bind(wifi, 'ssid'):as(tostring),
        }
    end)
end

---@param args { show_when_powered: boolean }
function module.Bluetooth(args)
    local bt = Bluetooth.get_default()
    local visible

    if args.show_when_powered then visible = bind(bt, 'is-powered') end

    return Widget.Image {
        icon_name = 'bluetooth-symbolic',
        visible = visible,
    }
end

function module.Volume(args)
    local wp = Wp.get_default()
    local speaker = wp.audio.default_speaker

    return Widget.Image {
        icon_name = bind(speaker, 'volume-icon'),
        tooltip_text = bind(speaker, 'volume'):as(function(volume)
            return string.format('%d%%', volume * 100)
        end),
    }
end

---@param args { show_when_muted?: boolean }
function module.Microphone(args)
    local wp = Wp.get_default()
    local mic = wp.audio.default_microphone

    local visible

    if args.show_when_muted then visible = bind(mic, 'mute') end

    return Widget.Image {
        icon_name = bind(mic, 'volume-icon'),
        visible = visible,
    }
end

---@param args { display_percentage?: boolean }
function module.Battery(args)
    local bat = Battery.get_default()

    return Widget.Box {
        css_classes = { 'gap-1' },
        Widget.Image {
            icon_name = bind(bat, 'battery-icon-name'),
        },
        args.display_percentage and Widget.Label {
            css_classes = { 'heading' },
            label = bind(bat, 'percentage'):as(function(p)
                return string.format('%d%%', p * 100)
            end),
        },
    }
end

---@param args { show_when_dnd?: boolean }
function module.NotifIcon(args)
    local notifd = Notifd.get_default()

    local visible

    if args.show_when_dnd then visible = bind(notifd, 'dont-disturb') end

    return Widget.Image {
        icon_name = bind(notifd, 'dont-disturb'):as(function(dnd)
            if dnd then return 'bell-outline-none' end
            return 'bell-outline'
        end),
        visible = visible,
    }
end

---@param args { path: string, size: integer, roundness: 'none'|'sm'|'md'|'lg'|'xl'|'2xl'|'3xl'|'full' }
function module.Avatar(args)
    if not args.roundness then args.roundness = 'full' end

    return Widget.Clamp {
        maximum_size = args.size,
        width_request = args.size,
        halign = 'CENTER',
        Widget.Clamp {
            maximum_size = args.size,
            height_request = args.size,
            orientation = 'VERTICAL',
            valign = 'CENTER',
            Widget.Picture {
                file = Gio.File.new_for_path(args.path),
                css_classes = { 'rounded-' .. args.roundness },
                content_fit = 'COVER',
            },
        },
    }
end

return module
