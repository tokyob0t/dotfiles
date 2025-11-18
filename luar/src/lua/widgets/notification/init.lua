local Icon = require('lua.widgets.icons')
local lookup_icon = require('lua.utils.lookup_icon')

---@class NotificationWidgetCtor
---@field notification AstalNotifd.Notification
---@field is_popup boolean
---@field setup? fun(self: Gtk.Box | Astalified4)
---@field on_expire? function
---@field on_hover_enter function
---@field on_hover_leave function

---@param args NotificationWidgetCtor
return function(args)
    local n = args.notification
    local shrink = Variable.new(not args.is_popup)

    local summary = Widget.Label {
        label = n.summary,
        css_classes = { 'title' },
        xalign = 0,
        lines = 1,
        max_width_chars = 20,
    }

    local body = Widget.Label {
        label = n.body,
        lines = 2,
        xalign = 0,
        max_width_chars = 1,
        wrap = true,
        hexpand = true,
        css_classes = { 'dimmed' },
        ellipsize = 'END',
    }

    local header = Widget.Box {
        css_classes = { 'gap-2', 'header' },
        Widget.Image {
            icon_name = lookup_icon(
                n.app_icon,
                n.desktop_entry,
                n.app_name,
                'application-x-executable'
            ),
        },
        Widget.Label {
            label = n.app_name,
            halign = 'START',
            hexpand = true,
            justify = 'LEFT',
            xalign = 0,
            css_classes = { 'heading' },
        },
        Widget.Label {
            label = os.date('%H:%M', n.time),
            css_classes = { 'heading' },
            halign = 'END',
        },
        Widget.Box {
            css_classes = { 'gap-2' },
            Widget.Button {
                css_classes = { 'min-w-0', 'image-button', 'min-h-0', 'rounded-full' },
                icon_name = bind(shrink):as(function(value)
                    return not value and 'down' or 'up'
                end):as(function(value)
                    return string.format('pan-%s-symbolic', value)
                end),
                on_clicked = function()
                    shrink.value = not shrink.value
                end,
            },
            Widget.Button {
                icon_name = 'window-close-symbolic',
                css_classes = { 'min-w-0', 'image-button', 'min-h-0', 'rounded-full' },
                on_clicked = function()
                    n:dismiss()
                end,
                on_hover_enter = function(self)
                    self:add_css_class('destructive-action')
                end,
                on_hover_leave = function(self)
                    self:remove_css_class('destructive-action')
                end,
            },
        },
    }

    local content = Widget.Revealer {
        reveal_child = bind(shrink):as(function(value)
            return not value
        end),
        on_destroy = function()
            shrink:drop()
        end,
        transition_duration = 200,
        Widget.Box {
            vertical = true,
            Widget.Box {
                css_classes = { 'gap-2' },
                (n.image and GLib.file_test(n.image, 'EXISTS')) and Icon.Avatar {
                    path = n.image,
                    roundness = 'xl',
                    size = 64,
                },
                Widget.Box {
                    vertical = true,
                    css_classes = { 'gap-1' },
                    summary,
                    body,
                },
            },
            (#n.actions > 0) and Widget.Box {
                css_classes = { 'gap-1', 'mt-2' },
                homogeneous = true,
                table.map(n.actions, function(action)
                    return Widget.Button {
                        label = action.label,
                        css_classes = { 'text-button', 'rounded-md' },
                        on_clicked = function()
                            n:invoke(action.id)
                        end,
                    }
                end),
            },
        },
    }

    return Widget.Box {
        css_classes = { 'notification', 'bg', 'p-2', 'rounded-2xl', 'gap-1', n.urgency },
        vertical = true,
        setup = args.setup,
        on_hover_enter = args.on_hover_enter,
        on_hover_leave = args.on_hover_leave,
        header,
        content,
    }
end
