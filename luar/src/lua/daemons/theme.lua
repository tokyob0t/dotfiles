local monitor_file = require('astal.file').monitor_file
local variant = require('lua.utils.variant')

local dir = GLib.get_user_config_dir() .. '/gtk-4.0'

local gnome = Gio.Settings {
    schema_id = 'org.gnome.desktop.interface',
}

local color_scheme = bind {
    get = function() return variant.decode(gnome:get_value('color-scheme')) end,
    subscribe = function(self, callback)
        local id = gnome.on_changed:connect(function(_, _key)
            if _key == 'color-scheme' then callback(self:get()) end
        end)

        return function() GObject.signal_handler_disconnect(gnome, id) end
    end,
}

return function()
    monitor_file(dir, function(file, event)
        if file == (dir .. '/gtk.css') then
            if event == 'CHANGED' and color_scheme:get() == 'prefer-light' then
                App:apply_css(file)
            end
        end

        if file == (dir .. '/gtk-dark.css') then
            if event == 'CHANGED' and color_scheme:get() == 'prefer-dark' then
                App:apply_css(file)
            end
        end

        if file == (dir .. '/gtk.css') or file == (dir .. '/gtk-dark.css') then
            if event == 'DELETED' then
                App:apply_css('resource://' .. package.resource .. '/styles.css', true)
            end
        end
    end)
end
