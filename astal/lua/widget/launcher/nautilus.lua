local map = require("lua.lib").map
local find = require("lua.lib").find

local SProvider = require("lua.widget.launcher.searchprovider")
local SearchProvider, SearchProviderWidget = SProvider[1], SProvider[2]

return function()
	local max_items = 10
	local NautilusSearchProvider = SearchProvider.new(
		"org.gnome.Nautilus",
		"/org/gnome/Nautilus/SearchProvider",
		"org.gnome.Shell.SearchProvider2"
	)
	return SearchProviderWidget.new("Nautilus", "org.gnome.Nautilus", max_items, NautilusSearchProvider)
end
