local gobject = require('lua.services.gobject')

---@class LuaDialog: GObject.Object
local Dialog = gobject.new('LuaDialog', {}, {})

---@param ctor { heading: string, body: string, on_response: fun(response: string) }
function Dialog:confirm(ctor)
    local new = Widget.AlertDialog {
        heading = ctor.heading,
        body = ctor.body,
        responses = {
            { id = 'deny', label = 'Deny' },
            { id = 'allow', label = 'Allow', appearance = 'SUGGESTED' },
        },
        on_response = function(_, response) ctor.on_response(response) end,
    }

    new:present()

    table.insert(self.priv.active_dialogs, new)
end

function Dialog:_init() self.priv.active_dialogs = {} end

local _instance

return {
    ---@return LuaDialog
    get_default = function()
        if _instance then return _instance end

        _instance = Dialog()

        return _instance
    end,
}
