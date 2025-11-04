local Apps = astal.require('AstalApps')
local Hyprland = astal.require('AstalHyprland')
local monitor_file = require('astal.file').monitor_file
local run_unattached = require('lua.utils.run_unattached')
local settings = require('lua.utils.settings')

local max_entries = settings('launcher-max-entries', 'u')
local excluded_apps = settings('launcher-excluded-entries', 'as')
local search_delay = settings('launcher-search-delay', 'u')

local apps = Apps.Apps {}

for _, dir in ipairs(GLib.get_system_data_dirs()) do
    local appsdir = dir .. 'applications'

    if GLib.file_test(appsdir, 'EXISTS') and GLib.file_test(appsdir, 'IS_DIR') then
        monitor_file(appsdir, function(_, event)
            if event == 'CREATED' or event == 'DELETED' then apps:reload() end
        end)
    end
end

---@param args { icon_name: string, name: string, description?: string, launch: function }
local function LauncherItem(args)
    return Widget.Button {
        css_classes = { 'flat' },
        on_clicked = function()
            if args.launch then args.launch() end
        end,
        on_focus_enter = function(self) self:add_css_class('highlight') end,
        on_focus_leave = function(self) self:remove_css_class('highlight') end,
        Widget.Box {
            css_classes = { 'gap-2' },

            Widget.Image {
                icon_name = args.icon_name,
                css_classes = { 'text-5g' },
            },

            Widget.Label {
                css_classes = { 'title' },
                xalign = 0,
                ellipsize = 'END',
                label = args.name,
            },

            args.description and Widget.Label {
                css_classes = { 'dimmed', 'body' },
                xalign = 0,
                max_width_chars = 30,
                ellipsize = 'END',
                lines = 1,
                label = args.description,
            },
        },
    }
end

---@param command string
local launch_unattached = function(command)
    command = tostring(command):gsub('%%[UuFfIiCcKk]', ''):gsub('%s+', ' '):match('^%s*(.-)%s*$')

    run_unattached(command)
end

local hide

---@type Gtk.SearchEntry | Astalified4
local search_entry

local query = Variable.new('')

local filtered = bind(query)
    :as(function(q) return q == '' and {} or apps:fuzzy_query(q) end)
    :as(function(array) return table.slice(array, 1, max_entries:get()) end)
    :as(function(array)
        return table.filter(array, function(app)
            for _, entry in ipairs(excluded_apps:get()) do
                if entry == app.entry then return false end
            end
            return true
        end)
    end)

local launcher = Widget.Window {
    name = 'launcher',
    application = App,
    visible = false,
    namespace = 'astal-launcher',
    keymode = 'ON_DEMAND',
    css_classes = { 'transparent' },
    anchor = { 'TOP', 'BOTTOM' },
    setup = function(self)
        hide = function() self:hide() end
    end,
    on_show = function() search_entry:grab_focus() end,
    on_hide = function() search_entry.text = '' end,
    -- on_key_pressed = function(_, keyval)
    --     local ESC = keyval == Gdk.KEY_Escape

    --     if ESC then hide() end
    -- end,
    Widget.Box {
        vertical = true,
        valign = 'START',
        css_classes = { 'p-2', 'vertical', 'gap-2', 'rounded-3xl', 'bg' },
        Widget.SearchEntry {
            placeholder_text = 'Type to Search...',
            valign = 'START',
            css_classes = { 'flat', 'm-2', 'p-0' },
            search_delay = search_delay,
            setup = function(self) search_entry = self end,
            on_search_changed = function(self) query.value = self.text or '' end,
            on_stop_search = function() hide() end,
            on_activate = function()
                ---@type AstalApps.Application?
                local app = filtered:get()[1]

                if app then hide(launch_unattached(app.executable)) end
            end,
        },
        Widget.Separator {
            visible = filtered:as(function(f) return #f > 0 end),
        },
        Widget.Box {
            vertical = true,
            valign = 'START',
            visible = filtered:as(function(f) return #f > 0 end),
            filtered:as(function(f)
                return table.map(f, function(app)
                    return LauncherItem {
                        name = app.name,
                        description = app.description,
                        icon_name = app.icon_name,
                        launch = function() hide(launch_unattached(app.executable)) end,
                    }
                end)
            end),
        },
    },
}
