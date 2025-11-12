local variant = require('lua.utils.variant')

local IFACE = 'org.gnome.Shell.SearchProvider2'

---@alias SearchProvider2.Meta { id: string, name: string, description: string, icon?: Gdk.Texture, gicon: Gio.Icon?, clipboard_text?: string }

---@type SearchProvider2[]
local registered = {}

---@class SearchProvider2
---@field desktop_id string
---@field bus_name string
---@field object_path string
---@field private proxy  Gio.DBusProxy | { async_call: fun(self: Gio.DBusProxy, method: string, parameters: GLib.Variant, flags: 'NONE'|Gio.DBusCallFlags, timeout: integer ): GLib.Variant }
---@overload fun(args: { desktop_id: string, bus_name: string, object_path: string })
local SearchProvider = {}

---@diagnostic disable-next-line
setmetatable(SearchProvider, {
    __call = function(_, args)
        return SearchProvider.new(args.desktop_id, args.bus_name, args.object_path)
    end,
})

SearchProvider.get_registered = function()
    return registered
end

---@param desktop_id string
---@param bus_name string
---@param object_path string
---@return SearchProvider2
function SearchProvider.new(desktop_id, bus_name, object_path)
    local new = setmetatable({
        desktop_id = desktop_id,
        bus_name = bus_name,
        object_path = object_path,
        proxy = Gio.DBusProxy {
            g_bus_type = 'SESSION',
            g_interface_name = IFACE,
            g_name = bus_name,
            g_object_path = object_path,
        },
    }, {
        __index = SearchProvider,
    })

    table.insert(registered, new)

    return new
end

---@param identifier string
---@param terms string[]
---@param timestamp integer
function SearchProvider:activate_result(identifier, terms, timestamp)
    -- stylua: ignore start 
    self.proxy
        :async_call('ActivateResult', GLib.Variant('(sasu)', { identifier, terms, timestamp }), 'NONE',-1)
    -- stylua: ignore end
end

---@param terms string[]
---@return string[] identifiers
function SearchProvider:get_initial_result_set(terms)
    local response =
        self.proxy:async_call('GetInitialResultSet', GLib.Variant('(as)', { terms }), 'NONE', -1)

    if not response then return {} end

    return variant.decode(response)[1]
end

---@async
---@param identifiers string[]
---@return SearchProvider2.Meta[]
function SearchProvider:get_result_metas(identifiers)
    local response =
        self.proxy:async_call('GetResultMetas', GLib.Variant('(as)', { identifiers }), 'NONE', -1)

    if not response then return {} end

    ---@type (GLib.Variant | { value: { id: string, name: string, description: string, icon?: GLib.Variant, gicon: string, ['icon-data']: table, clipboardText: string } } )[]
    local array = variant.decode(response, 2)[1]

    return table.map(array, function(var)
        local gicon, icon

        local icon_variant = var:lookup_value('icon')
        local gicon_string = var.value.gicon
        local icon_data = var.value['icon-data']

        if icon_variant then gicon = Gio.icon_deserialize(icon_variant) end
        if gicon_string then gicon = Gio.icon_new_for_string(gicon_string) end
        if icon_data then
            icon = Gdk.Texture.new_for_pixbuf(
                GdkPixbuf.Pixbuf.new_from_bytes(
                    GLib.Bytes(icon_data[7]),
                    GdkPixbuf.Colorspace.RGB,
                    icon_data[4],
                    icon_data[5],
                    icon_data[1],
                    icon_data[2],
                    icon_data[3]
                )
            )
        end

        return {
            id = var.value.id,
            name = var.value.name,
            description = var.value.description,
            icon = icon,
            gicon = gicon,
            clipboard_text = var.value.clipboardText,
        }
    end)
end

-- ---@param previous_results string[]
-- ---@param terms string[]
-- ---@return string results
-- function SearchProvider:get_subsearch_result_set(previous_results, terms) end

---@param terms string[]
---@param timestamp integer
function SearchProvider:launch_search(terms, timestamp)
    self.proxy:async_call('LaunchSearch', GLib.Variant('(asu)', { terms, timestamp }), 'NONE', -1)
end

return SearchProvider
