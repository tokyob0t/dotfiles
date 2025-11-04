---@class Varmap
---@field private variable AstalLuaVariable
---@field private map table
local Varmap = {}
Varmap.__index = Varmap

function Varmap.new(initial)
    initial = initial or {}
    return setmetatable({ variable = Variable.new {}, map = initial }, Varmap)
end

function Varmap:subscribe(callback) return self.variable:subscribe(callback) end

function Varmap:set(key, value)
    if Gtk.Widget:is_type_of(value) then value.no_implicit_destroy = true end
    self:delete(key)
    self.map[key] = value
    self:notify()
end

function Varmap:get()
    local tbl = {}

    for _, value in pairs(self.map) do
        table.insert(tbl, value)
    end

    return tbl
end

function Varmap:get_item(key) return self.map[key] end

---@private
function Varmap:notify() self.variable.value = self:get() end

function Varmap:delete(key)
    if Gtk.Widget:is_type_of(self.map[key]) then self.map[key].no_implicit_destroy = false end

    self.map[key] = nil
    self:notify()
end

return Varmap
