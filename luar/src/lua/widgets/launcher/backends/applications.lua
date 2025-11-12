local Apps = astal.require('AstalApps')
local monitor_file = require('astal.file').monitor_file
local LauncherItem = require('lua.widgets.launcher.launcheritem')
local run_unattached = require('lua.utils.run_unattached')
local settings = require('lua.utils.settings')

local max_entries = settings('launcher-max-entries', 'u')
local apps = Apps.Apps {}

---@param args { icon_name: string, max_items: integer}
return function(args)
    local max = function()
        return args.max_items or max_entries:get()
    end
    ---@type (Gtk.Revealer|Astalified4)[]
    local revealers = {}

    ---@type table<(Gtk.Revealer|Astalified4), AstalApps.Application>
    local map = {}

    local applications = Variable.new(apps.list)

    local in_use = Variable.new(false)

    for _, dir in ipairs(GLib.get_system_data_dirs()) do
        if dir:sub(-1) == '/' then dir = dir:sub(1, -2) end

        local appsdir = dir .. '/applications'

        if GLib.file_test(appsdir, 'EXISTS') and GLib.file_test(appsdir, 'IS_DIR') then
            monitor_file(appsdir, function(_, event)
                if event == 'CREATED' or event == 'DELETED' then
                    apps:reload()
                    applications.value = apps.list
                end
            end)
        end
    end

    return {
        filter = function(query)
            if not query or query:sub(1, 1) == ':' then
                in_use.value = false
                return table.iterate(revealers, function(r)
                    r.reveal_child = false
                end)
            end
            in_use.value = true

            local i = 0

            for _, rev in ipairs(revealers) do
                local app = map[rev]

                rev.reveal_child = apps:fuzzy_score(query, app) > apps.min_score and i < max()

                if rev.reveal_child then i = i + 1 end
            end
        end,
        children = bind(applications):as(function(_applications)
            revealers = {}
            map = {}

            ---@param app AstalApps.Application
            return table.map(_applications, function(app)
                return Widget.Revealer {
                    setup = function(self)
                        map[self] = app
                        table.insert(revealers, self)
                    end,
                    LauncherItem {
                        name = app.name,
                        icon_name = app.icon_name,
                        description = app.description,
                        launch = function()
                            local desktop = GioUnix.DesktopAppInfo.new(app.entry)

                            local command = tostring(desktop:get_string('Exec'))
                                :gsub('%%[UuFfIiCcKk]', '')
                                :gsub('%s+', ' ')
                                :match('^%s*(.-)%s*$')

                            run_unattached(command)
                            App:toggle_window('launcher')
                        end,
                    },
                }
            end)
        end),
        icon = Widget.Revealer {
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
        },
    }
end
