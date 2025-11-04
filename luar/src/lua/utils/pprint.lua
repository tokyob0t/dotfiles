return function(...)
    local printed_table = {}

    local function rprint(value, indent)
        if type(value) == 'table' then
            if printed_table[value] then return '<already printed>' end
            printed_table[value] = true

            local parts = { '{\n' }

            -- manejar índices numéricos consecutivos primero
            local i = 1
            while value[i] ~= nil do
                table.insert(parts, string.rep(' ', indent + 2) .. rprint(value[i], indent + 2) .. ',\n')
                i = i + 1
            end

            -- luego imprimir claves no numéricas o índices "sparse"
            for k, v in pairs(value) do
                if not (type(k) == 'number' and k >= 1 and k < i) then
                    local key = type(k) == 'string' and k or '[' .. tostring(k) .. ']'
                    table.insert(parts, string.rep(' ', indent + 2) .. key .. ' = ' .. rprint(v, indent + 2) .. ',\n')
                end
            end

            table.insert(parts, string.rep(' ', indent) .. '}')
            return table.concat(parts)
        elseif type(value) == 'string' then
            return '"' .. value .. '"'
        else
            return tostring(value)
        end
    end

    local args = {...}
    for i = 1, #args do
        io.stdout:write(rprint(args[i], 0) .. ' ')
    end
    io.stdout:write('\n')
end
