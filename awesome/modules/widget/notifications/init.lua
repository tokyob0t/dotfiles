local rnotification = require("ruled.notification")
local naughty = require("naughty")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local widget = wibox.widget
local cter = wibox.container

---@type theme
local bful = require("beautiful")

local utils = require("utils.init")
local user = require("user")

local apply_markup = function(text)
	text = utils.string.markdown_to_markup(text)
	text = utils.string.replace(text, "\n", "") or text
	return text
end

naughty.persistence_enabled = true
naughty.config.defaults.timeout = 5
naughty.config.defaults.ontop = false
naughty.config.defaults.title = "Awesome"
naughty.config.defaults.screen = awful.screen.focused()
naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.border_width = nil

rnotification.connect_signal("request::rules", function()
	rnotification.append_rule({
		rule = { urgency = "critical" },
		properties = { bg = "#ff0000", fg = "#ffffff" },
	})
	rnotification.append_rule({
		rule = {},
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
		},
	})
end)

---@param n naughty.notification
naughty.connect_signal("request::display", function(n)
	n.set_title = function(self, title)
		n._private.title = string.format(
			"<span font_weight='600' fgcolor='%s' font_family='Segoe UI Variable' size='%dpt'>%s</span>",
			bful.colorscheme.base04,
			dpi(12),
			apply_markup(title)
		)
		self:emit_signal("property::title", title)
	end

	n.set_message = function(self, message)
		n._private.message = string.format(
			"<span font_weight='500' fgcolor='%s' font_family='Segoe UI Variable Light' size='%dpt'>%s</span>",
			bful.colorscheme.base03,
			dpi(11),
			apply_markup(message)
		)
		self:emit_signal("property::message", message)
	end

	n:set_title(n.title)
	n:set_message(n.message)

	local icon_big = {
		widget = widget.imagebox,
		image = n.icon,
		halign = "center",
		valign = "center",
		forced_height = dpi(200),
		forced_width = dpi(200),
		clip_shape = utils.rrect(dpi(10)),
		visible = ternary(n.icon ~= nil, true, false)
			and ternary(utils.table.contains(user.ScreenshotApps, n.app_name), true, false),
	}

	local icon_smol = {
		widget = widget.imagebox,
		image = n.icon,
		valign = "center",
		halign = "center",
		forced_height = dpi(50),
		forced_width = dpi(50),
		clip_shape = utils.rrect(dpi(10)),
		visible = ternary(n.icon ~= nil, true, false)
			and ternary(not utils.table.contains(user.ScreenshotApps, n.app_name), true, false),
	}

	local head = {
		utils.table.override(
			{
				image = nil,
				widget = widget.imagebox,
				forced_height = nil,
				forced_width = nil,
				valign = "center",
			},
			ternary(
				n.app_name == "notify-send" or utils.table.contains(user.ScreenshotApps, n.app_name),
				{ image = bful.awesome_icon, forced_height = dpi(16), forced_width = dpi(16) },
				{
					image = utils.lookup_icon({
						icon_name = {
							utils.string.replace_with_table(n.app_name, user.ReplaceClientClassnames),
							n.app_name,
						},
						size = 32,
					}) or utils.lookup_icon({
						icon_name = { n.app_icon, "application-x-executable-symbolic" },
						size = 32,
						recolor = bful.fg_normal,
					}),
					forced_height = dpi(20),
					forced_width = dpi(20),
				}
			)
		),
		{
			widget = widget.textbox,
			font = "Segoe UI Variable " .. dpi(10.5),
			markup = "  " .. string.format(
				"<span font_weight='500'>%s</span>",
				utils.string.title(utils.string.replace_with_table(n.app_name, user.ReplaceClientClassnames))
			),
		},
		{
			{
				widget = widget.imagebox,
				image = utils.lookup_icon({
					icon_name = "more-small-symbolic",
					size = 16,
					recolor = bful.fg_normal,
				}),
				forced_width = dpi(16),
				forced_height = dpi(16),
			},
			{
				widget = widget.imagebox,
				image = utils.lookup_icon({
					icon_name = "cross-small-symbolic",
					size = 16,
					recolor = bful.fg_normal,
				}),
				forced_width = dpi(16),
				forced_height = dpi(16),
			},
			spacing = dpi(10),
			layout = wibox.layout.fixed.horizontal,
		},
		layout = wibox.layout.align.horizontal,
	}

	local body = {
		icon_smol,
		{
			{
				notification = n,
				widget = naughty.widget.title,
				ellipsize = "end",
			},
			{
				notification = n,
				widget = naughty.widget.message,
				ellipsize = "middle",
				wrap = "word",
			},
			fill_space = true,
			layout = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(5),
	}

	local feeeeeeeeet = {
		notification = n,
		widget = naughty.list.actions,
		style = { underline_normal = false },
		base_layout = widget({
			spacing = dpi(5),
			layout = wibox.layout.flex.horizontal,
		}),
		widget_template = {
			{
				id = "text_role",
				halign = "center",
				valign = "center",
				widget = widget.textbox,
				font = "Segoe UI Variable 700 " .. dpi(10),
			},
			bg = bful.bg_focus,
			shape = utils.rrect(5),
			widget = cter.background,
			forced_height = dpi(25),
		},
	}

	return naughty.layout.box({
		notification = n,
		shape = utils.rrect(dpi(10)),
		type = "notification",
		cursor = "hand2",
		widget_template = {
			{
				{
					icon_big,
					{
						{
							head,
							body,
							feeeeeeeeet,
							spacing = dpi(5),
							layout = wibox.layout.fixed.vertical,
						},
						left = bful.notification_margin,
						right = bful.notification_margin,
						widget = cter.margin,
					},
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(10),
				},
				top = bful.notification_margin,
				bottom = bful.notification_margin,
				widget = cter.margin,
			},
			id = "background_role",
			widget = cter.background,
			forced_width = bful.notification_width,
		},
	})
end)
