local bful = require("beautiful")

local _STR = {}

---@param str string
---@param delimiter? string
---@return table
_STR.split = function(str, delimiter)
	delimiter = delimiter or " "

	local parts = {}
	local pattern = "(.-)" .. delimiter
	local last_end = 1
	local s, e, cap = str:find(pattern, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(parts, cap)
		end
		last_end = e + 1
		s, e, cap = str:find(pattern, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(parts, cap)
	end
	return parts
end
_STR.escape_pattern = function(str)
	return string.gsub(str, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

---@param str string
---@return boolean
_STR.has_capital = function(str)
	return string.match(str, "%u") ~= nil
end

---@param str string
---@param old string
---@param new string
---@return string
_STR.replace = function(str, old, new)
	str = str or ""
	old = _STR.escape_pattern(old)
	str = string.gsub(str, old, new)
	return str
end

---@param str string
---@param myTable table
_STR.replaceWithTable = function(str, myTable)
	for old, new in pairs(myTable) do
		str = _STR.replace(str, old, new)
	end
	return str
end

---@param str string
---@param chars string
---@return string
_STR.strip = function(str, chars)
	chars = chars or "%s"
	local pattern = "^[" .. chars:gsub("([^%w])", "%%%1") .. "]*(.-)[" .. chars:gsub("([^%w])", "%%%1") .. "]*$"
	return str:match(pattern)
end

---@param str string
---@param chars string
---@return boolean
_STR.startswith = function(str, chars)
	return str:find("^" .. _STR.escape_pattern(chars)) ~= nil
end

---@param str string
---@param chars string
---@return boolean
_STR.endswith = function(str, chars)
	return str:find(_STR.escape_pattern(chars) .. "$") ~= nil
end

---@param str string
---@param color string
---@return string
_STR.colorize = function(str, color)
	return string.format("<span foreground='%s'>%s</span>", color, str)
end

---@param str string
---@return string
_STR.prettify = function(str)
	str = str:gsub("%W", "")
	return _STR.title(str)
end

---@param str string
---@return string
_STR.capitalize = function(str)
	return (str:gsub("^%l", string.upper))
end

---@param str string
---@return string
_STR.title = function(str)
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, _STR.capitalize(word))
	end
	return table.concat(words, " ")
end

---@param markdown string
---@return string
_STR.markdown_to_markup = function(markdown)
	markdown = _STR.replaceWithTable(require("lib.markdown")(markdown), {
		["<h1>"] = "<span size='xx-large'><b>",
		["</h1>"] = "</b></span>",

		["<h2>"] = "<span size='x-large'><b>",
		["</h2>"] = "</b></span>",

		["<h3>"] = "<span size='large'><b>",
		["</h3>"] = "</b></span>",

		["<h4>"] = "<span size='medium'><b>",
		["</h4>"] = "</b></span>",

		["<h5>"] = "<span size='small'><b>",
		["</h5>"] = "</b></span>",

		["<p>"] = "<span>",
		["</p>"] = "</span>",
		["<strong>"] = "<b>",
		["</strong>"] = "</b>",
		["<em>"] = "<i>",
		["</em>"] = "</i>",
		["<s>"] = "<span strikethrough='true'>",
		["</s>"] = "</span>",
		["<code>"] = "<span " .. string.format("background = '%s'", bful.bg_focus) .. string.format(
			"foreground= '%s'",
			bful.fg_normal
		) .. " weight='600' font_family='JetBrainsMono Nerd Font' size='10pt'>",
		["</code>"] = "</span>",
	})
	return markdown
end

return _STR
