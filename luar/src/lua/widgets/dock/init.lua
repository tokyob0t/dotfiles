local Hyprland = astal.require('AstalHyprland')
local Varmap = require('lua.utils.varmap')
local run_unattached = require('lua.utils.run_unattached')
local settings = require('lua.utils.settings')
local timeout = astal.timeout

local pinned_apps, set_pinned_apps = settings('dock-pinned-apps', 'as')

---@param command string
local launch_unattached = function(command)
    command = tostring(command):gsub('%%[UuFfIiCcKk]', ''):gsub('%s+', ' '):match('^%s*(.-)%s*$')

    run_unattached(command)
end

---@param args { class: string, on_clicked: function } | { desktop_entry: string } | { icon_name: string, tooltip_text: string, popover: Gtk.Popover | Astalified4, setup: fun(self: Gtk.Button) }
local function DockItem(args)
    if args.class then
        return DockItem {
            setup = args.setup,
            desktop_entry = args.class .. '.desktop',
        }
    end

    if args.desktop_entry then
        local desktop = GioUnix.DesktopAppInfo.new(args.desktop_entry)

        if not desktop then
            return DockItem {
                setup = args.setup,
                icon_name = 'application-x-executable',
                tooltip_text = args.class,
            }
        end

        local keyfile = GLib.KeyFile()

        keyfile:load_from_file(desktop.filename, 'NONE')

        local actions = table.map(desktop:list_actions(), function(action_name)
            return Widget.Button {
                css_classes = { 'flat', 'font-normal' },
                label = desktop:get_action_name(action_name),
                on_clicked = function()
                    launch_unattached(keyfile:get_string('Desktop Action ' .. action_name, 'Exec'))
                end,
            }
        end)

        local is_pinned = table.find(pinned_apps:get(), function(entry)
            return entry == args.desktop_entry
        end)

        return DockItem {
            setup = args.setup,
            icon_name = desktop:get_string('Icon'),
            tooltip_text = desktop:get_string('Name'),
            popover = Widget.Popover {
                visible = false,
                Widget.Box {
                    vertical = true,
                    actions,
                    Widget.Button {
                        label = is_pinned and 'Unpin' or 'Pin',
                        css_classes = { 'flat' },
                        on_clicked = function()
                            if is_pinned then
                                set_pinned_apps(table.filter(pinned_apps:get(), function(entry)
                                    return entry ~= args.desktop_entry
                                end))
                            else
                                set_pinned_apps {
                                    args.desktop_entry,
                                    table.unpack(pinned_apps:get()),
                                }
                            end
                        end,
                    },
                },
            },
        }
    end

    return Widget.Revealer {
        transition_type = 'SLIDE_UP',
        transition_duration = 200,
        reveal_child = false,
        setup = function(self)
            timeout(50, function()
                self.reveal_child = true
            end)
        end,
        Widget.MenuButton {
            tooltip_text = args.tooltip_text,
            css_classes = { 'flat', 'rounded-xl', 'p-1', 'min-h-8', 'min-w-8' },
            setup = args.setup,
            ---@param self Gtk.MenuButton
            on_button_released = function(self, button)
                if button == Gdk.BUTTON_PRIMARY and args.on_clicked then args.on_clicked() end
                if button == Gdk.BUTTON_SECONDARY and args.popover then self:popup() end
            end,
            Widget.Image {
                icon_name = args.icon_name,
                pixel_size = 46,
            },
            args.popover,
        },
    }
end

local function PinnedApps()
    return Widget.Box {
        Widget.Box {
            css_classes = { 'gap-1' },
            ---@param array string[]
            pinned_apps:as(function(array)
                return table.map(array, function(entry)
                    return DockItem {
                        desktop_entry = entry,
                    }
                end)
            end),
        },
        Widget.Separator {},
    }
end

local function HyprClients()
    local hypr = Hyprland.get_default()
    local clients = Varmap.new()
    local count = {}
    local by_address = {}

    ---@param c AstalHyprland.Client
    local add_client = function(c)
        -- if not is_real_window(c) then return end

        local is_pinned = table.find(pinned_apps:get(), function(app)
            return app == (c.initial_class .. '.desktop')
        end)

        if is_pinned then return end

        local class = c.initial_class
        local addr = c.address

        if not class or not addr then return end

        by_address[addr] = class

        if not count[class] then
            count[class] = 0
            clients:set(
                class,
                DockItem {
                    desktop_entry = class .. '.desktop',
                    -- setup = function(self) print(self) end,
                }
            )
        end

        count[class] = count[class] + 1
    end

    ---@param address string
    local remove_client = function(address)
        local class = by_address[address]

        if not class then return end

        by_address[address] = nil
        count[class] = (count[class] or 1) - 1

        if count[class] <= 0 then
            count[class] = nil

            ---@type Gtk.Revealer
            local revealer = clients:get_item(class)

            if revealer then
                revealer.reveal_child = false
                revealer.on_notify['child-revealed'] = function()
                    clients:delete(class)
                end
            end
        end
    end

    return Widget.Box {
        css_classes = { 'dock-clients', 'rounded-2xl' },
        setup = function(self)
            for _, c in ipairs(hypr.clients) do
                add_client(c)
            end

            self:hook(hypr, 'client-added', function(_, c)
                add_client(c)
            end)
            self:hook(hypr, 'client-removed', function(_, address)
                remove_client(address)
            end)

            local _array = pinned_apps:get()

            self.on_destroy = pinned_apps:subscribe(function(array)
                ---@type string[]
                local added = table.filter(array, function(entry)
                    return not table.contains(_array, entry)
                end)

                ---@type string[]
                local removed = table.filter(_array, function(entry)
                    return not table.contains(array, entry)
                end)

                if #added > 0 then
                    for _, entry in ipairs(added) do
                        for _, c in ipairs(hypr.clients) do
                            if (c.initial_class .. '.desktop') == entry then
                                remove_client(c.address)
                            end
                        end
                    end
                end

                if #removed > 0 then
                    for _, entry in ipairs(removed) do
                        for _, c in ipairs(hypr.clients) do
                            if (c.initial_class .. '.desktop') == entry then add_client(c) end
                        end
                    end
                end

                _array = array
            end)
        end,

        bind(clients),
    }
end

---@param args { gdkmonitor: Gdk.Monitor }
return function(args)
    return Widget.Window {
        anchor = { 'BOTTOM' },
        css_classes = { 'transparent', 'dock' },
        gdkmonitor = args.gdkmonitor,
        application = App,
        namespace = 'astal-dock',
        name = string.format('dock-%s', args.gdkmonitor.connector),
        exclusivity = 'EXCLUSIVE',
        Widget.Box {
            halign = 'CENTER',
            valign = 'END',
            css_classes = { 'rounded-3xl', 'bg', 'frame', 'p-1', 'gap-1' },

            PinnedApps(),
            -- HyprClients(),
        },
    }
end
