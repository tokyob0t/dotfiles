local gears = require("gears")
local _TABLE = {}

--- Function to check if an element is present in the table
---@param myTable table
---@param element any
---@return boolean
_TABLE.contains = function(myTable, element)
	for _, value in ipairs(myTable) do
		if value == element then
			return true
		end
	end
	return false
end

--- Function to find the index of an element in the table
---@param myTable table
---@param element any
---@return number | nil
_TABLE.index = function(myTable, element)
	for index, value in ipairs(myTable) do
		if value == element then
			return index
		end
	end
	return nil -- If the element is not found in the table
end

-- Function to find an element in the table using a comparison function
---@param myTable table
---@param func function
---@return any
_TABLE.find = function(myTable, func)
	for index, value in ipairs(myTable) do
		if func(value, index) then
			return value
		end
	end
	return nil
end

--- Function to create a new table by applying a function to each element of the original table
---@param myTable table
---@param func function
---@return table
_TABLE.map = function(myTable, func)
	local newTable = {}
	for _, value in ipairs(myTable) do
		table.insert(newTable, func(value))
	end
	return newTable
end

--- Function to modify the original table by applying a function to each element
---@param myTable table
---@param func function
---@return nil
_TABLE.foreach = function(myTable, func)
	for index, value in ipairs(myTable) do
		myTable[index] = func(value)
	end
end

--- It checks if at least one element in the table satisfies the condition defined by the given function.
---@param myTable table
---@param func function
---@return boolean
_TABLE.any = function(myTable, func)
	for _, value in ipairs(myTable) do
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

---@param myTable table
---@param func function
---@return table
_TABLE.filter = function(myTable, func)
	local t = {}
	for _, value in pairs(myTable) do
		if func(value) then
			table.insert(t, value)
		end
	end
	return t
end

return _TABLE
