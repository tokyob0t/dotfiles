local swww = require('swww')
local Hyprland = astal.require('AstalHyprland')

---@param args { gdkmonitor: Gdk.Monitor }
return function(args)
    local hypr = Hyprland.get_default()

    return Widget.Window {
        layer = 'BOTTOM',
        exclusivity = 'IGNORE',
        anchor = { 'TOP', 'LEFT', 'RIGHT', 'BOTTOM' },
        visible = false,
        gdkmonitor = args.gdkmonitor,
        css_classes = { 'transparent' },
        namespace = 'astal-wallpaper',
        setup = function(self) self.visible = true end,
        Widget.Box {
            Widget.Label {
                valign = 'END',
                css_classes = { 'text-xl', 'font-bold' },
                setup = async(function(self) self.label = hypr:async_message('splash') end),
            },
        },
    }
end
