local ApplicationsBackend = require('lua.widgets.launcher.backends.applications')
local SearchBackend = require('lua.widgets.launcher.backends.searchbackend')
local SearchProvider = require('lua.widgets.launcher.backends.searchprovider')

local backends = {
    ApplicationsBackend {
        icon_name = 'view-grid-symbolic',
        max_items = 10,
    },
    SearchBackend {
        icon_name = 'org.gnome.Nautilus-symbolic',
        prefix = ':f',
        provider = SearchProvider {
            bus_name = 'org.gnome.Nautilus',
            object_path = '/org/gnome/Nautilus/SearchProvider',
            desktop_id = 'org.gnome.Nautilus.desktop',
        },
    },
    SearchBackend {
        icon_name = 'com.belmoussaoui.Authenticator-symbolic',
        prefix = ':a',
        provider = SearchProvider {
            bus_name = 'com.belmoussaoui.Authenticator.SearchProvider',
            object_path = '/com/belmoussaoui/Authenticator/SearchProvider',
            desktop_id = 'com.belmoussaoui.Authenticator.desktop',
        },
    },
    -- Icon Library
    SearchBackend {
        icon_name = 'org.gnome.design.IconLibrary-symbolic',
        prefix = ':i',
        provider = SearchProvider {
            bus_name = 'org.gnome.design.IconLibrary.SearchProvider',
            object_path = '/org/gnome/design/IconLibrary/SearchProvider',
            desktop_id = 'org.gnome.design.IconLibrary.desktop',
        },
    },
    -- Contacts
    SearchBackend {
        icon_name = 'org.gnome.Contacts-symbolic',
        prefix = ':c',
        provider = SearchProvider {
            bus_name = 'org.gnome.Contacts.SearchProvider',
            object_path = '/org/gnome/Contacts/SearchProvider',
            desktop_id = 'org.gnome.Contacts.desktop',
        },
    },
    -- Clocks
    SearchBackend {
        icon_name = 'org.gnome.clocks-symbolic',
        prefix = ':cl',
        provider = SearchProvider {
            bus_name = 'org.gnome.clocks',
            object_path = '/org/gnome/clocks/SearchProvider',
            desktop_id = 'org.gnome.clocks.desktop',
        },
    },
    -- Characters
    SearchBackend {
        icon_name = 'org.gnome.Characters-symbolic',
        prefix = ':ch',
        provider = SearchProvider {
            bus_name = 'org.gnome.Characters',
            object_path = '/org/gnome/Characters/SearchProvider',
            desktop_id = 'org.gnome.Characters.desktop',
        },
    },
    -- Calendar
    SearchBackend {
        icon_name = 'org.gnome.Calendar-symbolic',
        prefix = ':ca',
        provider = SearchProvider {
            bus_name = 'org.gnome.Calendar',
            object_path = '/org/gnome/Calendar/SearchProvider',
            desktop_id = 'org.gnome.Calendar.desktop',
        },
    },
    -- Calculator
    SearchBackend {
        icon_name = 'org.gnome.Calculator-symbolic',
        prefix = ':calc',
        provider = SearchProvider {
            bus_name = 'org.gnome.Calculator.SearchProvider',
            object_path = '/org/gnome/Calculator/SearchProvider',
            desktop_id = 'org.gnome.Calculator.desktop',
        },
    },
}

return function()
    local childrens = table.map(backends, function(b)
        return b.children
    end)

    local icons = table.map(backends, function(b)
        return b.icon
    end)

    ---@param query? string
    local filter = function(query)
        if not query or query == '' then
            return table.iterate(backends, function(b)
                return b.filter()
            end)
        end

        return table.iterate(backends, function(b)
            b.filter(query)
        end)
    end

    return filter, childrens, icons
end
