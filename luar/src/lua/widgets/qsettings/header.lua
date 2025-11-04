local AccountsService = astal.require('AccountsService')
local Icons = require('lua.widgets.icons')

---@param args { check_interval: integer }
local function Packages(args)
    local count = Variable.new(0):poll(args.check_interval, { 'paru', '-Qu' }, function(next, prev)
        local count = 0

        for _ in next:gmatch('[^\n]*\n?') do
            count = count + 1
        end

        return count
    end)

    return Widget.Box {
        Widget.Image {
            icon_name = bind(count):as(function(c)
                if c > 100 then return 'software-update-urgent-symbolic' end
                if c > 0 then return 'software-update-available-symbolic' end

                return 'emblem-ok-symbolic'
            end),
        },
        Widget.Label {
            label = bind(count):as(function(c)
                if c > 100 then return '+99 Updates' end
                if c > 0 then return string.format('%d Updates', c) end
                return 'Up to date :)'
            end),
        },
    }
end

return function()
    local manager = AccountsService.UserManager.get_default()
    local me = manager:get_user(GLib.get_user_name())

    return Widget.Box {
        valign = 'START',
        Widget.Box {
            halign = 'CENTER',
            valign = 'CENTER',
            Icons.Avatar {
                path = me.icon_file,
                roundness = 'xl',
                size = 64,
            },
        },
        Widget.Box {
            vertical = true,
            Packages {
                check_interval = 3600000,
            },
        },
    }
end
