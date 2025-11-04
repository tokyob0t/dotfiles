local Hyprland = astal.require('AstalHyprland')

---@param command string
return function(command)
    local hypr = Hyprland.get_default()

    hypr:dispatch('exec', command)

    return true
end
