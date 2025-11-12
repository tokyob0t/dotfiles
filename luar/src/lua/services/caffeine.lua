local timeout = astal.timeout
local gobject = require('lua.services.gobject')

---@class LuaCaffeineService: GObject.Object
local Caffeine = gobject.new('LuaCaffeineService', {}, {
    active = { 'boolean', 'rw' },
})

function Caffeine:_init()
    self.priv.active = false
    self.priv.cookie = 0
end

---@param duration_ms integer?
function Caffeine:activate(duration_ms)
    if duration_ms then
        self.priv.cookie = App:inhibit(nil, 'IDLE')

        self.priv.timeout = timeout(duration_ms, function()
            App:uninhibit(self.priv.cookie)
            self.priv.cookie, self.priv.timeout = 0, nil
        end)
    end
end

local _instance

return {
    ---@return LuaCaffeineService
    get_default = function()
        if _instance then return _instance end
        _instance = Caffeine()

        return _instance
    end,
}
