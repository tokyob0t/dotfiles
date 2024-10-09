local M = {}

---@param path string
---@return string
M.src = function(path)
	local str = debug.getinfo(2, "S").source:sub(2)
	local src = str:match("(.*/)") or str:match("(.*\\)") or "./"
	return src .. path
end

---@generic T, R
---@param tbl T[]
---@param fn fun(T, i:integer): R
---@return R[]
M.map = function(tbl, fn)
	local new_tbl = {}
	for i, v in ipairs(tbl) do
		new_tbl[i] = fn(v, i)
	end
	return new_tbl
end

---@generic T
---@param tbl T[]
---@param fn? fun(T, i:integer): boolean
---@return T | nil
M.find = function(tbl, fn)
	fn = fn or function(value, index)
		return value
	end

	for index, value in ipairs(tbl) do
		if fn(value, index) then
			return value
		end
	end
end

---@generic T, R
---@param tbl T[]
---@param fn fun(T, i:integer): R
M.foreach = function(tbl, fn)
	for i, v in ipairs(tbl) do
		tbl[i] = fn(v, i)
	end
end

---@generic T[]
---@param fn fun(T, i: integer | string): boolean
M.filter = function(tbl, fn)
	local copy = {}
	for key, value in pairs(tbl) do
		if fn(value, key) then
			if type(key) == "number" then
				table.insert(copy, value)
			else
				copy[key] = value
			end
		end
	end
	return copy
end

return M
