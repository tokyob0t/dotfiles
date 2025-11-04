if not table.unpack then table.unpack = unpack end

local GLib = astal.require('GLib')

---@generic T
---@param tbl T[]
---@param ... T
---@return number
table.push = function(tbl, ...)
    for _, value in ipairs { ... } do
        table.insert(tbl, value)
    end
    return #tbl
end

---@generic T
---@param tbl T[]
---@param ... T
---@return number
table.unshift = function(tbl, ...)
    local items = { ... }

    for i = #items, 1, -1 do
        table.insert(tbl, 1, items[i])
    end

    return #tbl
end

---@generic T
---@param tbl T[]
---@param ... T
---@return T
table.append = function(tbl, ...)
    local new_tbl = {}

    for _, value in ipairs(tbl) do
        table.insert(new_tbl, value)
    end

    for _, value in ipairs { ... } do
        table.insert(new_tbl, value)
    end

    return new_tbl
end

---@generic T
---@param tbl T[]
---@param ... T
---@return T
table.prepend = function(tbl, ...)
    local new_tbl = {}

    for _, value in ipairs { ... } do
        table.insert(new_tbl, value)
    end

    for _, value in ipairs(tbl) do
        table.insert(new_tbl, value)
    end

    return new_tbl
end

---@generic T, R
---@param tbl T[]
---@param fn fun(value: T, index: integer, tbl: T[]): R?
---@return R[]
table.map = function(tbl, fn)
    local new_tbl = {}
    for index, value in ipairs(tbl) do
        local v = fn(value, index, tbl)
        if v then table.insert(new_tbl, v) end
    end
    return new_tbl
end

---@generic T
---@param tbl T[]
---@param fn fun(value: T, index: integer, tbl: T[]): boolean
---@return T?, integer?
table.find = function(tbl, fn)
    for index, value in ipairs(tbl) do
        if fn(value, index, tbl) then return value, index end
    end
end

---@generic T
---@param tbl T[]
---@param fn fun(value: T, index: integer, tbl: T[]): boolean?
---@return boolean
table.any = function(tbl, fn)
    for index, value in ipairs(tbl) do
        if fn(value, index, tbl) then return true end
    end
    return false
end

---@generic T
---@param tbl T[]
---@param fn fun(value: T, index: integer, tbl: T[]): any
table.iterate = function(tbl, fn)
    for index, value in ipairs(tbl) do
        fn(value, index, tbl)
    end
end

---@generic T
---@param tbl T[]
---@param fn fun(value: T, index: integer, tbl: T[]): boolean
---@return T[]
table.filter = function(tbl, fn)
    local new_tbl = {}
    for index, value in ipairs(tbl) do
        if fn(value, index, tbl) then table.insert(new_tbl, value) end
    end
    return new_tbl
end

---@generic R
---@param props { from?: number, to: number, interval?: number }
---@param fn fun(i: number): R
---@return R[]
table.from = function(props, fn)
    props.from = props.from or 1
    props.interval = props.interval or 1

    fn = fn or function(i) return i end

    local tbl = {}

    for i = props.from, props.to, props.interval do
        table.insert(tbl, fn(i))
    end

    return tbl
end

---@param tbl table
---@return boolean
table.contains = function(tbl, item)
    return not not table.find(tbl, function(value) return value == item end)
end

---@generic T: table
---@param tbl T
---@param n number
---@param m? number
---@return T
table.slice = function(tbl, n, m)
    local copy = {}

    m = m or #tbl

    m = math.min(m, #tbl)

    for i = n, m do
        table.insert(copy, tbl[i])
    end

    return copy
end

---@generic K
---@param tbl table<K, any>
---@return K[]
table.keys = function(tbl)
    local new_tbl = {}
    for key in pairs(tbl) do
        table.insert(new_tbl, key)
    end

    return new_tbl
end

---@param s string
---@param tbl string[]
---@return string
string.join = function(s, tbl) return table.concat(tbl, s) end

string.title = function(s) return string.gsub(' ' .. s, '%W%l', string.upper):sub(2) end

string.capitalize = function(s) return string.gsub(s, '^%l', string.upper) end

---@param s string
---@param delimiter? string
---@param max_splits? number
---@return string[]
string.split = function(s, delimiter, max_splits)
    delimiter = delimiter or '%s'

    local result = {}
    local count = 0

    if #s == 0 then return result end

    for match in string.gmatch(s, '([^' .. delimiter .. ']+)') do
        if max_splits and count == max_splits then
            table.insert(result, match)
            count = count + 1
        else
            table.insert(result, s:sub(#s - #match + 1))
            break
        end
    end

    return result
end

---@diagnostic disable-next-line
math.randomseed = function(x) GLib.random_set_seed(x) end

---@diagnostic disable-next-line
math.random = function(m, n)
    if not m and not n then
        return GLib.random_double()
    elseif m and not n then
        return GLib.random_int_range(1, m + 1)
    else
        return GLib.random_int_range(m, n + 1)
    end
end

---@return number
math.clamp = function(x, min, max) return math.max(min, math.min(x, max)) end

os.setenv = GLib.setenv
os.getenv = GLib.getenv
os.unsetenv = GLib.unsetenv

---@diagnostic disable-next-line
os.time = function(date)
    if date then
        return GLib.DateTime
            .new_local(date.year, date.month, date.day, date.hour or 0, date.min or 0, date.sec or 0)
            :to_unix()
    end
    return GLib.DateTime.new_now_local():to_unix()
end

---@diagnostic disable-next-line
os.date = function(format, time)
    local fecha

    if time then
        fecha = GLib.DateTime.new_from_unix_local(time)
    else
        fecha = GLib.DateTime.new_now_local()
    end

    if format then
        return fecha:format(format)
    else
        return fecha:format('%c')
    end
end
