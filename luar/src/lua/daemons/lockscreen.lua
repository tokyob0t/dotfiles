local LockScreen = require('lua.widgets.lockscreen')
local SessionLock = require('lua.services.sessionlock')

return function()
    local lock = SessionLock.get_default()

    lock.on_monitor = function(_, gdkmonitor)
        LockScreen {
            setup = function(self) lock:assign_window_to_monitor(self, gdkmonitor) end,
            on_unlocked = function() lock:unlock() end,
        }
    end
end
