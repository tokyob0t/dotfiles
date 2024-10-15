local map = require("lua.lib").map
local find = require("lua.lib").find

local SProvider = require("lua.widget.launcher.searchprovider")
local SearchProvider, SearchProviderWidget = SProvider[1], SProvider[2]

return function()
	local max_items = 10
	local IconLibrarySearchProvider = SearchProvider.new(
		"org.gnome.design.IconLibrary.SearchProvider",
		"/org/gnome/design/IconLibrary/SearchProvider",
		"org.gnome.Shell.SearchProvider2"
	)
	return SearchProviderWidget.new(
		"Icon Library",
		"org.gnome.design.IconLibrary",
		max_items,
		IconLibrarySearchProvider
	)
end
