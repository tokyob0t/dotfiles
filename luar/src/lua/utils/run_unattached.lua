local Hyprland = astal.require('AstalHyprland')
local subprocess = require('astal.process').subprocess
local exec_async = require('astal.process').exec_async

local XDG_CURRENT_DESKTOP = os.getenv('XDG_CURRENT_DESKTOP')

if XDG_CURRENT_DESKTOP == 'Hyprland' then
    local hypr = Hyprland.get_default()
    ---@return boolean
    return function(command)
        hypr:dispatch('exec', command)
        return true
    end
elseif XDG_CURRENT_DESKTOP == 'fht-compositor' then
    return function(command)
        exec_async {
            'fht-compositor',
            'ipc',
            'action',
            'run-command-line',
            '--command-line',
            command,
        }
        return true
    end
end

---@param command string
---@return boolean
return function(command)
    local _ = subprocess(command, function(out) end, function(err) end)

    return true
end
