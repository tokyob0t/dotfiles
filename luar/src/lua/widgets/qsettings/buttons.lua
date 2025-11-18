---@alias AttachArgs { grid: Gtk.Grid | Astalified4, column: number, row: number, width: number?, height?: number }

---@alias ButtonArgs { icon?: Gtk.Widget, icon_name?: string | AstalLuaBinding, label: string | AstalLuaBinding, setup?: fun(self: Gtk.ToggleButton | Astalified4)  }

local module = {}

---@param args AttachArgs | ButtonArgs
function module.ToggleButton(args)
    return Widget.ToggleButton {
        setup = function(self)
            args.width, args.height = args.width or 1, args.height or 1
            args.grid:attach(self, args.column, args.row, args.width, args.height)
            if args.setup then args.setup(self) end
        end,
        on_notify_active = function(self, active)
            self:toggle_css_class('highlight', active)
        end,
        Widget.Box {
            css_classes = { 'gap-2', 'min-h-10', 'min-w-20' },
            args.icon,
            args.icon_name and Widget.Image {
                icon_name = args.icon_name,
            },
            Widget.Label {
                label = args.label,
                halign = 'CENTER',
                justify = 'CENTER',
                xalign = 0.5,
            },
        },
    }
end

---@param args AttachArgs | ButtonArgs
function module.SimpleButton(args)
    return Widget.Button {
        setup = function(self)
            args.width, args.height = args.width or 1, args.height or 1
            args.grid:attach(self, args.column, args.row, args.width, args.height)
        end,
        Widget.Box {
            css_classes = { 'gap-2' },
            args.icon,
            args.icon_name and Widget.Image {
                icon_name = args.icon_name,
            },
            Widget.Label {
                label = args.label,
                halign = 'CENTER',
                justify = 'CENTER',
                xalign = 0.5,
            },
        },
    }
end

return module
