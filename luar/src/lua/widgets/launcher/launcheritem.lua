---@param args { icon_name: AstalLuaBinding|string?, gicon: AstalLuaBinding|Gio.Icon?, paintable: AstalLuaBinding|Gdk.Paintable, name: AstalLuaBinding|string, description?: AstalLuaBinding|string, launch: function }
return function(args)
    return Widget.Button {
        css_classes = { 'flat', 'px-2', 'py-1', 'rounded-xl', 'launcher-item' },
        on_activate = args.launch,
        -- on_clicked = args.launch,
        on_focus_enter = function(self)
            self:add_css_class('bg-alt')
        end,
        on_focus_leave = function(self)
            self:remove_css_class('bg-alt')
        end,
        Widget.Box {
            css_classes = { 'gap-2' },

            Widget.Image {
                icon_name = args.icon_name,
                paintable = args.paintable,
                gicon = args.gicon,
            },

            Widget.Label {
                label = args.name,
                css_classes = { 'title' },
                xalign = 0,
                ellipsize = 'END',
                halign = 'START',
            },

            args.description and Widget.Label {
                label = args.description,
                lines = 1,
                xalign = 0,
                max_width_chars = 1,
                wrap = true,
                hexpand = true,
                ellipsize = 'END',
                css_classes = { 'dimmed', 'body' },
            },
        },
    }
end
