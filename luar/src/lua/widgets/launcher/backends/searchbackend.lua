local LauncherItem = require('lua.widgets.launcher.launcheritem')
local async_exec = require('astal.process').async_exec
local settings = require('lua.utils.settings')
local max_entries = settings('launcher-max-entries', 'u')

local wl_copy = function(...)
    return async_exec { 'wl-copy', ... }
end

---@param args { icon_name: string, provider: SearchProvider2, max_items?: integer, prefix?: string }
return function(args)
    local provider, prefix, max_items = args.provider, args.prefix, args.max_items

    ---@type (Gtk.Revealer|Astalified4)[]
    local revealers = {}

    ---@type AstalLuaVariable<boolean>, AstalLuaVariable<SearchProvider2.Meta[]>
    local in_use, items = Variable.new(false), Variable.new {}

    ---@type Gtk.Revealer | Astalified4
    local icon = Widget.Revealer {
        reveal_child = bind(in_use),
        transition_type = 'SLIDE_LEFT',
        css_classes = { 'transition-opacity', 'duration-1000' },
        on_notify_reveal_child = function(self, reveal_child)
            self:toggle_css_class('opacity-0', not reveal_child)
            self:toggle_css_class('opacity-100', reveal_child)
        end,
        Widget.Image {
            css_classes = { 'text-accent' },
            icon_name = args.icon_name,
        },
    }

    local max = function()
        return max_items or max_entries:get()
    end

    ---@param query string
    ---@return boolean
    local supports = function(query)
        if not prefix then return true end
        return query:sub(1, #prefix) == prefix
    end

    local filter = async(function(query)
        if not query or not supports(query) then
            in_use.value = false

            return table.iterate(revealers, function(r)
                r.reveal_child = false
            end)
        end

        in_use.value = true

        local q = string.split(query, ' ')

        if prefix then table.remove(q, 1) end

        if #q == 0 then return items:set {} end

        items:set(
            provider:get_result_metas(table.slice(provider:get_initial_result_set(q), 1, max()))
        )
    end)

    local children = table.from({ to = max() }, function(i)
        ---@type AstalLuaBinding<SearchProvider2.Meta?>
        local item = bind(items):as(function(_items)
            return table.find(_items, function(_, index)
                return index == i
            end)
        end)

        return Widget.Revealer {
            reveal_child = item:as(function(_item)
                return not not _item
            end),
            setup = function(self)
                table.insert(revealers, self)
            end,
            LauncherItem {
                name = item:as(function(_item)
                    return _item and _item.name or ''
                end),
                gicon = item:as(function(_item)
                    return _item and _item.gicon or nil
                end),
                paintable = item:as(function(_item)
                    return _item and _item.icon or nil
                end),
                description = item:as(function(_item)
                    return _item and _item.description or ''
                end),
                launch = async(function()
                    local _item = item:get()

                    if _item then
                        provider:activate_result(_item.id, {}, 0)

                        if _item.clipboard_text then
                            wl_copy('--type', 'text/plain', _item.clipboard_text)
                        end

                        App:toggle_window('launcher')
                    end
                end),
            },
        }
    end)

    return {
        filter = filter,
        prefix = prefix,
        children = children,
        icon = icon,
    }
end
