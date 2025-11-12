local Hyprland = astal.require('AstalHyprland')
local subprocess = require('astal.process').subprocess

local hypr = Hyprland.get_default()

if hypr then
    ---@return boolean
    return function(command)
        hypr:dispatch('exec', command)
        return true
    end
end

---@param command string
---@return boolean
return function(command)
    local _ = subprocess(command, function(out) end, function(err) end)

    return true
end
