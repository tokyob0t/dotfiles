local Theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())

---@overload fun(name: string): string?
---@overload fun(name: string, ...: string): string
local function lookup_icon(name, ...)
    local fallback = { ... }

    name = tostring(name)

    for _, value in ipairs {
        name,
        name:lower(),
        name:upper(),
        name:capitalize(),
    } do
        local icon_info = Theme:lookup_icon(value, nil, 512, 1, 'NONE', 'NONE')
        if icon_info and icon_info.icon_name ~= 'image-missing' then return value end
    end

    if #fallback > 0 then return lookup_icon(table.remove(fallback, 1), table.unpack(fallback)) end
end

return lookup_icon
