local map = require("lua.lib").map
local find = require("lua.lib").find

local SProvider = require("lua.widget.launcher.searchprovider")
local SearchProvider, SearchProviderWidget = SProvider[1], SProvider[2]

return function()
	local max_items = 2
	local CalculatorSearchProvider = SearchProvider.new(
		"org.gnome.Calculator.SearchProvider",
		"/org/gnome/Calculator/SearchProvider",
		"org.gnome.Shell.SearchProvider2"
	)
	return SearchProviderWidget.new("Calculator", "org.gnome.Calculator", max_items, CalculatorSearchProvider)
end
