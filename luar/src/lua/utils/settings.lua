local variant = require('lua.utils.variant')

local settings = Gio.Settings {
    schema_id = package.domain,
}

---@param key string
---@param signature string | 's' | 'b' | 'i' | 'u' | 'd' | 'v' | 'as' | 'a{sv}'
---@return AstalLuaBinding
---@return fun(value: any)
return function(key, signature)
    local getter = function()
        return variant.decode(settings:get_value(key))
    end
    local setter = function(value)
        if value ~= getter() then settings:set_value(key, GLib.Variant(signature, value)) end
    end

    local binding = {
        get = function()
            return getter()
        end,
        subscribe = function(_, callback)
            local id = settings.on_changed:connect(function(_, _key)
                if _key == key then callback(getter()) end
            end)

            return function()
                GObject.signal_handler_disconnect(settings, id)
            end
        end,
    }

    return bind(binding), setter
end
