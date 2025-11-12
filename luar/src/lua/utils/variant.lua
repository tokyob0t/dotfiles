local basic_types = {
    b = 'boolean',
    y = 'number',
    n = 'number',
    q = 'number',
    i = 'number',
    u = 'number',
    t = 'number',
    s = 'string',
    d = 'number',
    o = 'string',
    g = 'string',
}

--- Gracias chatgpt por tanto, perdon por tan poco
--- @param v GLib.Variant
--- @param depth? integer  -- Nivel máximo de decodificación (por defecto: infinito)
--- @param level? integer  -- Nivel actual (interno)
--- @return string|number|boolean|table|GLib.Variant
local function decode_variant(v, depth, level)
    if type(v) ~= 'userdata' or not v.type then return v end

    local t = v.type
    if not t then return nil end

    level = level or 0
    depth = depth or math.huge

    -- Si ya llegamos al límite de profundidad, no decodificar más
    if level >= depth then return v end

    -- Maybe type (mX)
    if t:sub(1, 1) == 'm' then
        if v.value == nil then
            return nil
        else
            return decode_variant(GLib.Variant(t:sub(2), v.value), depth, level + 1)
        end
    end

    -- Variant type (v)
    if t == 'v' then return decode_variant(v.value, depth, level + 1) end

    -- Scalar simple
    if t:match('^[bynqiuotsdg]$') then return v.value end

    -- Diccionario (a{...})
    if t:match('^a{.+}$') then
        local result = {}
        for i = 0, #v - 1 do
            local entry = v:get_child_value(i)
            if entry then
                local key = decode_variant(entry[1], depth, level + 1)
                local value = decode_variant(entry[2], depth, level + 1)
                result[key] = value
            end
        end
        return result
    end

    -- Array genérico (aX)
    if t:sub(1, 1) == 'a' then
        local arr = {}
        for i = 0, #v - 1 do
            arr[i + 1] = decode_variant(v:get_child_value(i), depth, level + 1)
        end
        return arr
    end

    -- Tuple ((...))
    if t:match('^%(.+%)$') then
        local tuple = {}
        for i = 0, #v - 1 do
            tuple[i + 1] = decode_variant(v:get_child_value(i), depth, level + 1)
        end
        return tuple
    end

    -- Entry {key, value}
    if t:match('^{.+}$') then
        local entry = {}
        entry[1] = decode_variant(v:get_child_value(0), depth, level + 1)
        entry[2] = decode_variant(v:get_child_value(1), depth, level + 1)
        return entry
    end

    -- fallback
    return v.value
end

local function encode_variant(signature, value)
    -- Si ya es GLib.Variant, devolverlo tal cual
    if type(value) == 'userdata' and GLib.Variant:is_type_of(value) then return value end

    -- Maybe type
    if signature:sub(1, 1) == 'm' then
        local inner_sig = signature:sub(2)
        if value == nil then
            return GLib.Variant(signature, nil)
        else
            return encode_variant(inner_sig, value)
        end
    end

    -- Variant type
    if signature == 'v' then
        if type(value) == 'userdata' and GLib.Variant:is_type_of(value) then
            return value
        else
            local t = type(value)
            if t == 'string' then
                return GLib.Variant('s', value)
            elseif t == 'number' then
                return GLib.Variant('d', value)
            elseif t == 'boolean' then
                return GLib.Variant('b', value)
            else
                error('Cannot auto-convert value to variant: ' .. tostring(value))
            end
        end
    end

    -- Tipos básicos
    if basic_types[signature] then return GLib.Variant(signature, value) end

    -- Diccionario a{KV}
    local key_type, val_type = signature:match('^a{(%w)(%w)}$')
    if key_type and val_type then
        if type(value) ~= 'table' then
            error('Expected table for dictionary value, got ' .. type(value))
        end
        local tbl = {}
        for k, v in pairs(value) do
            local key = tostring(k)
            local val = encode_variant(val_type, v)
            tbl[key] = val
        end
        return GLib.Variant(signature, tbl)
    end

    -- Array genérico aX
    if signature:sub(1, 1) == 'a' then
        local elem_sig = signature:sub(2)
        if type(value) ~= 'table' then error('Expected table for array, got ' .. type(value)) end
        local arr = {}
        for i, v in ipairs(value) do
            arr[i] = encode_variant(elem_sig, v)
        end
        return GLib.Variant(signature, arr)
    end

    -- Tuples (...)
    if signature:match('^%(.+%)$') then
        local s = signature:sub(2, -2)
        local inner_types = {}
        local i = 1
        while i <= #s do
            local c = s:sub(i, i)
            if c == '(' then
                local level = 1
                local j = i + 1
                while j <= #s do
                    local cc = s:sub(j, j)
                    if cc == '(' then
                        level = level + 1
                    elseif cc == ')' then
                        level = level - 1
                    end
                    if level == 0 then break end
                    j = j + 1
                end
                table.insert(inner_types, s:sub(i, j))
                i = j + 1
            elseif c == 'a' and s:sub(i + 1, i + 1) == '{' then
                local j = i + 2
                while j <= #s do
                    if s:sub(j, j) == '}' then break end
                    j = j + 1
                end
                table.insert(inner_types, s:sub(i, j))
                i = j + 1
            else
                table.insert(inner_types, c)
                i = i + 1
            end
        end

        -- Caso especial: (sv)
        if #inner_types == 2 and inner_types[1] == 's' and inner_types[2] == 'v' then
            local key, val = value[1], value[2]
            local val_variant = encode_variant('v', val)
            return GLib.Variant('(sv)', { key, val_variant })
        end

        local inner = {}
        for idx, t in ipairs(inner_types) do
            inner[idx] = encode_variant(t, value[idx])
        end
        return GLib.Variant(signature, inner)
    end

    -- Diccionario simple {sv}
    if signature == '{sv}' then
        local key, val = value[1], value[2]
        local val_variant = encode_variant('v', val)
        return GLib.Variant('{sv}', { key, val_variant })
    end

    error('Unsupported signature: ' .. tostring(signature))
end

-- ========

return {
    decode = decode_variant,
    encode = encode_variant,
}
