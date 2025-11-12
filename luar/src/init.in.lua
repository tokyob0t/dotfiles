#!@lua@

package.name, package.domain, package.resource, package.version =
    '@name@', '@domain@', '@resource@', '@version@'

require('lua.preload')
require('lua.globals')
require('lua.functions')

Gio.resources_register(Gio.Resource.load('@gresourcePath@'))

Gtk.IconTheme
    .get_for_display(Gdk.Display.get_default())
    :add_resource_path(package.resource .. '/icons')

local Bar = require('lua.widgets.bar')
local Dock = require('lua.widgets.dock')
local NotifPopups = require('lua.widgets.notifpopups')
local QSettingsPanel = require('lua.widgets.qsettings').QSettingsPanel
local Wallpaper = require('lua.widgets.wallpaper')

App:start {
    instance_name = package.name,
    css = 'resource://' .. package.resource .. '/styles.css',
    main = function()
        require('lua.daemons')
        require('lua.widgets.clipboard')
        require('lua.widgets.launcher')

        local bars, docks, notifpopups, qsettings, walls = {}, {}, {}, {}, {}

        ---@param index integer
        ---@param gdkmonitor Gdk.Monitor
        local added = function(gdkmonitor, index)
            bars[index] = Bar { gdkmonitor = gdkmonitor }
            -- docks[index] = Dock { gdkmonitor = gdkmonitor }
            notifpopups[index] = NotifPopups { gdkmonitor = gdkmonitor }
            qsettings[index] = QSettingsPanel { gdkmonitor = gdkmonitor }
            -- walls[index] = Wallpaper { gdkmonitor = gdkmonitor }
        end

        for index, gdkmonitor in ipairs(App.monitors) do
            added(gdkmonitor, index)
        end

        App:on_monitor_added(added)

        App:on_monitor_removed(function(index)
            table.iterate({ bars, docks, notifpopups, qsettings, walls }, function(tbl)
                if tbl[index] then tbl[index]:destroy() end
            end)
        end)
    end,
    request_handler = function(args, response)
        local recorder = require('lua.services.recorder').get_default()
        local sessionlock = require('lua.services.sessionlock').get_default()

        for _, value in ipairs(args) do
            if value == 'lock' then return response('ok'), sessionlock:lock() end
            if value == 'screenshot' then return response('ok'), recorder:screenshot(false) end
            if value == 'screenshot-full' then return response('ok'), recorder:screenshot(true) end
        end

        response('non ok')
    end,
}
