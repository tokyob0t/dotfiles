local GLib = astal.require('GLib')
local GObject = astal.require('GObject')
local Gtk = astal.require('Gtk')

local module = {}

---@enum (key) PSPEC_FLAG
module.pspec_flag = {
    r = 'READABLE',
    w = 'WRITABLE',
    rw = 'READWRITE',
    priv = 'PRIVATE',
    ctor = 'CONSTRUCT',
    ['ctor-only'] = 'CONSTRUCT_ONLY',
}

---@enum (key) PSPEC_TYPE
module.pspec_type = {
    string = function(name, flags)
        return GObject.param_spec_string(name, name, name, '', flags)
    end,
    float = function(name, flags)
        return GObject.param_spec_float(name, name, name, -1, 1, 0, flags)
    end,
    int = function(name, flags)
        return GObject.param_spec_int(name, name, name, GLib.MININT32, GLib.MAXINT32, 0, flags)
    end,
    double = function(name, flags)
        return GObject.param_spec_double(name, name, name, GLib.MININT32, GLib.MAXINT32, 0, flags)
    end,
    boolean = function(name, flags)
        return GObject.param_spec_boolean(name, name, name, false, flags)
    end,
    gobject = function(name, flags)
        return GObject.param_spec_object(name, name, name, GObject.Object._gtype, flags)
    end,
    widget = function(name, flags)
        return GObject.param_spec_object(name, name, name, Gtk.Widget._gtype, flags)
    end,
    dummy = function(name, flags)
        --- this does nothing, its just a more expressive way to do it
        --- this is made to store lua tables or more complex data-types
        return GObject.param_spec_boolean(name, name, name .. '-dummy', false, flags)
    end,
}

---@param name string
---@param type PSPEC_TYPE
---@param flags PSPEC_FLAG[]
---@return GObject.ParamSpec
module.pspec = function(name, type, flags)
    return module.pspec_type[type](name, flags)
end

---@generic T: GObject.Object
---@param gobject T | { _property: table }
---@param pspecs table<string, (PSPEC_TYPE | PSPEC_FLAG)[]>
---@return T
module.install_pspecs = function(gobject, pspecs)
    for key, value in pairs(pspecs) do
        ---@type PSPEC_FLAG[]
        local flags = table.filter(value, function(v)
            return module.pspec_flag[v] ~= nil
        end)

        flags = table.map(value, function(v)
            return module.pspec_flag[v]
        end)

        flags = table.filter(flags, function(v)
            return not not v
        end)

        if #flags == 0 then table.insert(flags, 'READWRITE') end

        ---@type PSPEC_TYPE
        ---@diagnostic disable-next-line:assign-type-mismatch
        local data_type = table.find(value, function(v)
            return module.pspec_type[v] ~= nil
        end)

        gobject._property[key] = module.pspec(key, data_type, flags)
    end

    return gobject
end

module.install_signals = function(gobject, signals) end

---@param gobject GObject.Object
---@param gtype_name string
---@param properties table<string, (PSPEC_TYPE | PSPEC_FLAG)[]>
---@return GObject.Object
module.derive = function(gobject, gtype_name, signals, properties)
    local new_gobject = gobject:derive(gtype_name)
    module.install_pspecs(new_gobject, properties)
    module.install_signals(new_gobject, signals)
    return new_gobject
end

---@param gtype_name string
---@param properties table<string, (PSPEC_TYPE | PSPEC_FLAG)[]>
---@return GObject.Object
module.new = function(gtype_name, signals, properties)
    return module.derive(GObject.Object, gtype_name, signals, properties)
end

return module
