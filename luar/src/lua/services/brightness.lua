local Gio = astal.require('Gio')
local gobject = require('lua.services.gobject')
local file, process = require('astal.file'), require('astal.process')

---@class LuaBrightnessService: GObject.Object
local Brightness = gobject.new('LuaBrightnessService', {}, {
    screen = { 'float' },
    kbd = { 'float' },
})

function Brightness:_init()
    self.priv.screen, self.priv.kbd = 0, 0
end

Brightness.register_screen = async(function(self)
    local device = assert(process.async_exec('ls /sys/class/backlight')):match('([^\n]*)')

    local path = '/sys/class/backlight/' .. device
    local screen = path .. '/brightness'
    local screen_max = path .. '/max_brightness'

    local max = tonumber(assert(file.async_read_file(screen_max)))

    local update = async(function()
        local br = tonumber(assert(file.async_read_file(screen))) / max

        if br ~= self.screen then
            self.priv.screen = br
            self:notify('screen')
        end
    end)

    update()

    file.monitor_file(screen, function(_, event)
        if event == 'CHANGED' then update() end
    end)
end)

Brightness.register_keyboard = async(function(self)
    local proxy = Gio.DBusProxy {
        g_name = 'org.freedesktop.UPower',
        g_object_path = '/org/freedesktop/KbdBacklight',
        g_interface_name = 'org.freedesktop.Upower.KbdBacklight',
        g_connection = Gio.async_bus_get('SYSTEM'),
    }

    proxy.on_g_signal = function() print('wea') end
end)

local _instance

return {
    ---@return LuaBrightnessService
    get_default = function()
        if _instance then return _instance end

        _instance = Brightness {}

        _instance:register_screen()
        _instance:register_keyboard()

        return _instance
    end,
}
