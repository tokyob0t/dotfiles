local AccountsService = astal.require('AccountsService')
local Auth = astal.require('AstalAuth')
local monitor_file = require('astal.file').monitor_file
local timeout = astal.timeout

local manager = AccountsService.UserManager.get_default()
local me = manager:get_user(GLib.get_user_name())

local authenticating = Variable.new(false)

---@param password string
---@param callback fun(ok: boolean)
local auth = function(password, callback)
    Auth.Pam.authenticate(password, function(_, task)
        local status = Auth.Pam.authenticate_finish(task)

        callback(status == 0)
    end)
end

---@param args { on_unlocked: function, on_failed: function, on_authenticating: function, on_authenticating_done: function }
local function AuthPasswordEntry(args)
    return Widget.PasswordEntry {
        show_peek_icon = true,
        css_classes = { 'rounded-xl' },
        on_changed = function(self) self:remove_css_class('error') end,
        on_activate = function(self)
            self.sensitive = false

            if args.on_authenticating then args.on_authenticating() end

            auth(self.text, function(ok)
                self.sensitive = true
                self.text = ''

                if args.on_authenticating_done then args.on_authenticating_done() end

                if ok then
                    if args.on_unlocked then args.on_unlocked() end
                else
                    self:add_css_class('error')
                    self:add_css_class('shake')
                    timeout(300, function() self:remove_css_class('shake') end)
                    if args.on_failed then args.on_failed() end
                end
            end)
        end,
    }
end

---@param args { state: AstalLuaBinding<'locked'|'authenticating'> }
local function AuthStatusIcon(args)
    return Widget.Box {
        Widget.Spinner {
            visible = args.state:as(function(value) return value == 'authenticating' end),
        },
        Widget.Image {
            icon_name = 'system-lock-screen-symbolic',
            visible = args.state:as(function(value) return value == 'locked' end),
        },
    }
end

local function UserInfo()
    local custom_image

    if me.icon_file and GLib.file_test(me.icon_file, 'EXISTS') then
        custom_image = Gdk.Texture.new_from_filename(me.icon_file)
    end

    return Widget.Avatar {
        size = 96,
        show_initials = true,
        text = me.user_name,
        custom_image = custom_image,
    },
        Widget.Box {
            css_classes = { 'gap-2' },
            halign = 'CENTER',
            Widget.Image {
                icon_name = 'folder-user-symbolic',
            },
            Widget.Label {
                label = me.user_name,
                css_classes = { 'heading' },
            },
        }
end

---@param args { on_unlocked: function }
local function AuthCard(args)
    local avatar, user_name = UserInfo()

    return Widget.Box {
        hexpand = true,
        vexpand = true,
        halign = 'CENTER',
        valign = 'CENTER',
        css_classes = { 'gap-4', 'vertical' },
        vertical = true,

        Widget.Box {
            css_classes = { 'min-h-16', 'min-w-16', 'gap-2' },
            halign = 'CENTER',
            vertical = true,
            avatar,
            user_name,
        },

        Widget.Box {
            css_classes = { 'gap-2' },
            halign = 'CENTER',

            AuthStatusIcon {
                state = bind(authenticating):as(
                    function(value) return value and 'authenticating' or 'locked' end
                ),
            },

            AuthPasswordEntry {
                on_unlocked = args.on_unlocked,
                on_authenticating = function() authenticating.value = true end,
                on_authenticating_done = function() authenticating.value = false end,
            },
        },
    }
end

local function Wallpaper()
    local dotconfig = GLib.get_user_config_dir()
    local background = dotconfig .. '/lockscreen'

    if not GLib.file_test(background, 'EXISTS') then background = dotconfig .. '/background' end

    local image = Variable.new()

    return Widget.Picture {
        hexpand = true,
        vexpand = true,
        content_fit = 'FILL',
        paintable = bind(image),
        -- css_classes = { 'blur-lg' },
        setup = function(self)
            local exists = function() return GLib.file_test(background, 'EXISTS') end
            local reload = function() image.value = Gdk.Texture.new_from_filename(background) end

            if exists() then reload() end

            local monitor = monitor_file(background, function(_, event)
                if event == 'RENAMED' and exists() then reload() end
            end)

            self.on_destroy = function() monitor:cancel() end
        end,
    }
end

---@param args { setup: fun(self:  Gtk.Window | Astalified4), on_unlocked: function }
return function(args)
    ---@type function, function
    local reveal, unreveal

    return Widget.Window {
        visible = false,
        setup = args.setup,
        css_classes = { 'lockscreen' },
        on_realize = function() timeout(10, reveal) end,
        Widget.Revealer {
            reveal_child = false,
            transition_duration = 300,
            transition_type = 'SLIDE_DOWN',
            setup = function(self)
                reveal = function() self.reveal_child = true end
                unreveal = function() self.reveal_child = false end
            end,
            Widget.Overlay {
                Wallpaper(),
                AuthCard {
                    on_unlocked = function()
                        unreveal()
                        timeout(300, args.on_unlocked)
                    end,
                },
            },
        },
    }
end
