local Gtk4SessionLock = astal.require('Gtk4SessionLock')

local _instance

return {
    ---@return Gtk4SessionLock.Instance
    get_default = function()
        if _instance then return _instance end

        _instance = Gtk4SessionLock.Instance.new()

        return _instance
    end,
}
