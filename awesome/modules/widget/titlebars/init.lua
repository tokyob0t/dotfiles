local client = client
local bful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local utils = require("utils.init")
local user = require("user")
local widget = wibox.widget
local cter = wibox.container

local new_button = function(args)
	local button = widget({
		forced_width = dpi(50),
		widget = cter.background,
		shape = utils.rrect(dpi(15)),
		bg = bful.bg_normal,
		buttons = {
			awful.button({}, 1, args.callback),
		},
	})

	args.c:connect_signal("focus", function()
		button.bg = bful.bg_normal
	end)

	args.c:connect_signal("unfocus", function()
		button.bg = bful.bg_focus
	end)

	return button
end

client.connect_signal("request::titlebars", function(c)
	if utils.table.contains(user.ExcludedTitlebars.byClassName, c.class) then
		return
	end
	local left_side, right_side, minimizebutton, closebutton, maximizebutton

	local titlebar = awful.titlebar(c, { size = dpi(40), position = "top" })

	-- Left
	left_side = {
		--awful.titlebar.widget.iconwidget(c),
		{
			{
				id = "icon",
				widget = widget.imagebox,
				halign = "center",
				valign = "center",
				image = utils.lookup_icon({
					icon_name = {
						utils.string.replace_with_table(c.class, user.ReplaceClientClassnames),
						c.class,
						c.icon_name,
					},
					size = 32,
				}) or c.icon or utils.lookup_icon({ icon_name = "application-x-executable", size = 32 }),
			},
			margins = dpi(2.5),
			widget = cter.margin,
		},
		layout = wibox.layout.fixed.horizontal,
	}

	-- Right
	minimizebutton = new_button({
		c = c,
		callback = function()
			c.minimized = not c.minimized
		end,
	})

	maximizebutton = new_button({
		c = c,
		callback = function()
			c.maximized = not c.maximized
		end,
	})

	closebutton = new_button({
		c = c,
		callback = function()
			c:kill()
		end,
	})

	right_side = {
		{
			minimizebutton,
			maximizebutton,
			closebutton,
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
		},
		top = dpi(5),
		bottom = dpi(5),
		widget = cter.margin,
	}

	titlebar.widget = {
		{
			left_side,
			nil,
			right_side,
			layout = wibox.layout.align.horizontal,
		},
		right = dpi(10),
		left = dpi(10),
		top = dpi(5),
		bottom = dpi(5),
		widget = cter.margin,
		buttons = {
			awful.button({}, 1, function()
				c:activate({ context = "titlebar", action = "mouse_move" })
			end),
		},
	}
end)
