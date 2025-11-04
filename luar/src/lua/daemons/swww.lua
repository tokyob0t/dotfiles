local monitor_file = require('astal.file').monitor_file
local swww = require('lua.utils.swww')

local BACKGROUND = GLib.get_user_config_dir() .. '/background'

return function()
    monitor_file(
        BACKGROUND,
        async(function(_, event)
            if event == 'RENAMED' then
                swww(
                    'img',
                    BACKGROUND,
                    '--all',
                    '--transition-type',
                    'fade',
                    '--transition-fps',
                    '144',
                    '--transition-duration',
                    '3',
                    '--filter',
                    'Lanczos3'
                )
            end
        end)
    )
end
