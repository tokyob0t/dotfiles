-- https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Wallpaper.html

local file = require('astal.file')
local pprint = require('lua.utils.pprint')
local variant = require('lua.utils.variant')

local NAME = 'org.freedesktop.impl.portal.desktop.lua'
local PATH = '/org/freedesktop/portal/desktop'

local BACKGROUND = GLib.get_user_config_dir() .. '/background'
local LOCKSCREEN = GLib.get_user_config_dir() .. '/lockscreen'

local IFACE_INFO = Gio.DBusInterfaceInfo {
    name = 'org.freedesktop.impl.portal.Wallpaper',
    methods = {
        Gio.DBusMethodInfo {
            name = 'SetWallpaperURI',
            in_args = {
                Gio.DBusArgInfo { name = 'handle', signature = 'o' },
                Gio.DBusArgInfo { name = 'app_id', signature = 's' },
                Gio.DBusArgInfo { name = 'parent_window', signature = 's' },
                Gio.DBusArgInfo { name = 'uri', signature = 's' },
                Gio.DBusArgInfo { name = 'options', signature = 'a{sv}' },
            },
            out_args = {
                Gio.DBusArgInfo { name = 'response', signature = 'u' },
            },
        },
    },
}

---@param _ Gio.DBusConnection
---@param sender string
---@param path string
---@param name string
---@param method string
---@param args GLib.Variant
---@param callback Gio.DBusMethodInvocation
local handle_method_call = async(function(_, sender, path, name, method, args, callback)
    ---@param number 0|1|2
    local res = function(number) callback:return_value(GLib.Variant('u', { number })) end

    if method ~= 'SetWallpaperURI' then return res(2) end

    ---@type string, string, string, string, { ['set-on']: 'lockscreen'|'background'|'both' }
    local handle, app_id, parent_window, uri, options = table.unpack(variant.decode(args))

    local file_path = string.sub(uri, 8)

    if not GLib.file_test(file_path, 'EXISTS') then return res(1) end

    file.read_file_async(file_path, function(contents)
        if options['set-on'] == 'lockscreen' then
            file.write_file_async(LOCKSCREEN, contents)
        elseif options['set-on'] == 'background' then
            file.write_file_async(BACKGROUND, contents)
        elseif options['set-on'] == 'both' then
            file.write_file_async(LOCKSCREEN, contents)
            file.write_file_async(BACKGROUND, contents)
        end
    end)

    res(1)
end)

---@diagnostic disable
return async(function()
    if GLib.get_os_info('ID') ~= 'arch' then return end

    local bus = Gio.async_bus_get('SESSION')

    Gio.bus_own_name(
        'SESSION',
        NAME,
        'NONE',
        GObject.Closure(
            function(conn)
                conn:register_object(PATH, IFACE_INFO, GObject.Closure(handle_method_call))
            end
        )
        -- GObject.Closure(function(...) print('acquired') end),
        -- GObject.Closure(function(...) print('failed') end)
    )
end)
