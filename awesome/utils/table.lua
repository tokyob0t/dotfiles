local gears = require("gears")
local _TABLE = {}

--- Function to check if an element is present in the table
---@param t table
---@param element any
---@return boolean
_TABLE.contains = function(t, element)
	for _, value in ipairs(t) do
		if value == element then
			return true
		end
	end
	return false
end

--- Function to find the index of an element in the table
---@param t table
---@param element any
---@return number | nil
_TABLE.index = function(t, element)
	for index, value in ipairs(t) do
		if value == element then
			return index
		end
	end
	return nil -- If the element is not found in the table
end

-- Function to find an element in the table using a comparison function
---@param t table
---@param func fun(value:any, index:any): boolean
---@return any
_TABLE.find = function(t, func)
	for index, value in pairs(t) do
		if func(value, index) then
			return value
		end
	end
	return nil
end

--- Function to create a new table by applying a function to each element of the original table
---@param t table
---@param func function
---@return table
_TABLE.map = function(t, func)
	local newTable = {}
	for _, value in ipairs(t) do
		table.insert(newTable, func(value))
	end
	return newTable
end

--- Function to modify the original table by applying a function to each element
---@param t table
---@param func fun(value, index): any
---@return nil
_TABLE.foreach = function(t, func)
	for index, value in pairs(t) do
		t[index] = func(value, index)
	end
end

--- It checks if at least one element in the table satisfies the condition defined by the given function.
---@param t table
---@param func function
---@return boolean
_TABLE.any = function(t, func)
	for _, value in ipairs(t) do
		if func(value) then
			return true
		end
	end
	return false
end

---Override elements in the target table with values from the source table.
---@param target table
---@param source table
---@return table
_TABLE.override = function(target, source)
	return gears.table.crush(target, source, false)
end

---@param t table
---@param func function
---@return table
_TABLE.filter = function(t, func)
	local new_t = {}
	for _, value in pairs(t) do
		if func(value) then
			table.insert(new_t, value)
		end
	end
	return new_t
end

---@param t number[]
---@return number
_TABLE.sum = function(t)
	local r = 0
	for _, value in ipairs(t) do
		r = r + value
	end
	return r
end

---@param t table
---@return table
_TABLE.get_keys = function(t)
	local k = {}
	for key, _ in pairs(t) do
		table.insert(k, key)
	end
	return k
end

---@param t table
---@return table
_TABLE.get_values = function(t)
	local v = {}
	for _, value in pairs(t) do
		table.insert(v, value)
	end
	return v
end

---@param t table
---@return number
_TABLE.len = function(t)
	local l = 0
	for _ in pairs(t) do
		l = l + 1
	end
	return l
end

return _TABLE
