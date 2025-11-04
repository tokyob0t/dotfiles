---@diagnostic disable:inject-field

local Battery = astal.require('AstalBattery')
local notify = require('lua.utils.notify')
local settings = require('lua.utils.settings')

local low = settings('battery-low', 'u')
local low_notify = settings('battery-low-notify', 'b')
local charging_notify = settings('battery-charging-notify', 'b')

return function()
    local battery = Battery.get_default()

    battery.on_notify.percentage = function()
        local p = math.floor(battery.percentage * 100)

        if
            low_notify:get()
            and not battery.charging
            and (p == low:get() or p == (low:get() / 2))
        then
            notify {
                icon = battery.icon_name,
                appname = 'Battery',
                summary = 'Low Battery',
                body = string.format(
                    'Your battery is at %d%%. Please plug in your charger soon to avoid shutdown.',
                    p
                ),
            }
        end
    end

    battery.on_notify.charging = function()
        if battery.charging and charging_notify:get() then
            notify {
                icon = battery.icon_name,
                appname = 'Battery',
                summary = 'Now Charging',
                body = 'Your device is connected to a power source and is charging.',
            }
        end
    end
end
