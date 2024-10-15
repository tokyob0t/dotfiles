local map = require("lua.lib").map
local find = require("lua.lib").find

local SProvider = require("lua.widget.launcher.searchprovider")
local SearchProvider, SearchProviderWidget = SProvider[1], SProvider[2]

return function()
	local max_items = 10
	local CartridgesSearchProvider = SearchProvider.new(
		"page.kramo.Cartridges.SearchProvider",
		"/page/kramo/Cartridges/SearchProvider",
		"org.gnome.Shell.SearchProvider2"
	)
	return SearchProviderWidget.new("Cartridges", "page.kramo.Cartridges", max_items, CartridgesSearchProvider)
end
