local gears = require("gears")
local utils = require("utils.init")
local Gio = utils.Gio

---@class App
---@field new fun(app: Gio.DesktopAppInfo): App
---@field app Gio.DesktopAppInfo Gets the desktop application information.
---@field name string Gets the name of the application.
---@field generic_name string Gets the generic name of the application.
---@field display_name string Gets the display name of the application.
---@field comment string Gets the comment of the application.
---@field categories string Gets the categories of the application.
---@field desktop string Gets the desktop identifier of the application.
---@field icon_name string Gets the icon name of the application.
---@field keywords string Gets the keywords of the application.
---@field match fun(self, terms: string):boolean
---@field launch function Launches the application.
local App = {
	name = "",
	generic_name = "",
	display_name = "",
	comment = "",
	categories = "",
	desktop = "",
	icon_name = "",
}

---@param app Gio.AppInfo
App.new = function(app)
	local self = gears.object({
		class = setmetatable({}, {
			__index = App,
			__newindex = function(_, key)
				error("Attempt to modify read-only attribute: " .. key, 1)
			end,
		}),
		enable_properties = true,
	})

	if not app then
		error("El parámetro 'app' no puede ser nil")
	end

	-- Inicializar propiedades
	self.app = app
	self.desktop = app:get_id()
	self.name = app:get_name()
	self.comment = app:get_description() or ""
	self.categories = app:get_categories() or ""
	self.icon_name = app:get_string("Icon") or "application-x-executable"

	return self
end

App.launch = function(self)
	return self.app:launch()
end

---@param terms string
App.match = function(self, terms)
	terms = string.lower(terms)
	for _, value in ipairs({ self.name, self.comment, self.categories, self.icon_name }) do
		value = string.lower(value)
		if string.find(value, terms) then
			return true
		end
	end
	return false
end

setmetatable(App, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

---@class Applications
local Applications = {}

---@return App[]
Applications.get_all = function()
	local apps = {}

	for _, i in pairs(Gio.DesktopAppInfo.get_all()) do
		if i:should_show() then
			table.insert(apps, App.new(i))
		end
	end

	return apps
end

---@param input string
---@return App[]
Applications.query = function(input)
	local apps = {}

	for _, value in pairs(Applications.get_all()) do
		if value:match(input) then
			table.insert(value)
		end
	end
	return apps
end

return Applications
