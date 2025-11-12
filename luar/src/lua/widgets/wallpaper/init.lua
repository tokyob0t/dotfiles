---@param args { gdkmonitor: Gdk.Monitor }
return function(args)
    return Widget.Window {
        layer = 'BOTTOM',
        exclusivity = 'IGNORE',
        anchor = { 'TOP', 'LEFT', 'RIGHT', 'BOTTOM' },
        gdkmonitor = args.gdkmonitor,
        css_classes = { 'transparent' },
        namespace = 'astal-wallpaper',
    }
end
