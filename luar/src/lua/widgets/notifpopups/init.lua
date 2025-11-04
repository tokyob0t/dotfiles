local Dialog = require('lua.services.dialog')
local NotifWidget = require('lua.widgets.notification')
local Notifd = astal.require('AstalNotifd')
local Varmap = require('lua.utils.varmap')
local settings = require('lua.utils.settings')
local timeout = astal.timeout

local notif_timeout = settings('notifications-timeout', 'u')
local allowed_apps, set_allowed_apps = settings('notifications-allowed-apps', 'as')
local denied_apps, set_denied_apps = settings('notifications-denied-apps', 'as')

local function is_allowed(app_name)
    return table.find(allowed_apps:get(), function(_app_name) return app_name == _app_name end)
end

local function is_blocked(app_name)
    return table.find(denied_apps:get(), function(_app_name) return app_name == _app_name end)
end

---@param on_response fun(response: string)
local function ask_user(app_name, on_response)
    local dialog = Dialog.get_default()

    dialog:confirm {
        heading = 'Allow Notifications',
        body = app_name .. ' would like to send you notifications. Do you want to allow it?',
        on_response = on_response,
    }
end

---@param args { gdkmonitor: Gdk.Monitor, anchor: ('TOP' | 'RIGHT' | 'LEFT' | 'BOTTOM' )[] }
return function(args)
    local notifd = Notifd.get_default()
    notifd.ignore_timeout = true

    local notifications = Varmap.new()

    ---@param notif AstalNotifd.Notification
    local added = function(notif)
        local id = notif.id
        local cancel = timeout(notif_timeout:get(), function() notifications:delete(id) end)

        NotifWidget {
            notification = notif,
            is_popup = true,
            setup = function(this) notifications:set(id, this) end,
            on_hover_enter = function() cancel() end,
            on_hover_leave = function()
                cancel = timeout(notif_timeout:get(), function() notifications:delete(id) end)
            end,
        }
    end

    return Widget.Window {
        layer = 'OVERLAY',
        anchor = args.anchor or { 'TOP' },
        css_classes = { 'transparent', 'mt-2' },
        namespace = 'astal-notifpopup',
        application = App,
        gdkmonitor = args.gdkmonitor,
        name = string.format('notifpopup-%s', args.gdkmonitor.connector),
        visible = bind(notifications):as(function(notifs) return #notifs > 0 end),
        Widget.Box {
            css_classes = { 'gap-1' },
            vertical = true,
            setup = function(self)
                self:hook(notifd, 'notified', function(_, id)
                    if notifd.dont_disturb then return end

                    local notif = notifd:get_notification(id)
                    local name = notif.app_name

                    if is_blocked(name) then return notif:dismiss() end
                    if App:get_window('lockscreen') then return end
                    if is_allowed(name) then return added(notif) end

                    ask_user(notif.app_name, function(response)
                        if response == 'close' then
                            notif:dismiss()
                        elseif response == 'deny' then
                            set_denied_apps(table.append(denied_apps:get(), name))
                        elseif response == 'allow' then
                            set_allowed_apps(table.append(allowed_apps:get(), name))
                            added(notif)
                        end
                    end)
                end)
                self:hook(notifd, 'resolved', function(_, id) notifications:delete(id) end)
            end,
            bind(notifications),
        },
    }
end
