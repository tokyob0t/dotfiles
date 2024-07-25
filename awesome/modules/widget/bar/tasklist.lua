local wibox = require("wibox")
local awful = require("awful")
---@type theme
local bful = require("beautiful")
local user = require("user")

local rubato = require("lib.rubato")
local color = require("lib.color")

local utils = require("utils.init")
local dpi = utils.dpi

local get_color = function(col)
	local my_color = {}
	my_color.r, my_color.g, my_color.b = color.utils.hex_to_rgba(col)
	my_color = color.color(my_color)
	return my_color
end

local a_color = get_color(bful.tasklist_bg_focus)
local n_color = get_color(bful.tasklist_bg_normal)
local a_to_n = color.transition(n_color, a_color, 0)

return function(screen)
	local mytasklist = awful.widget.tasklist({
		screen = screen,
		filter = awful.widget.taglist.filter.all,
		style = { shape = utils.rrect(utils.dpi(10)) },
		layout = {
			spacing = dpi(5),
			halign = "center",
			layout = wibox.layout.fixed.horizontal,
		},
		buttons = {
			awful.button({}, 1, function(c)
				c:activate({ context = "tasklist", action = "toggle_minimization", switch_to_tag = true })
			end),
			awful.button({}, 3, function(c)
				c:activate({ context = "tasklist", action = "toggle_minimization", switch_to_tag = true })
			end),
		},
	})

	local icon = {
		{
			id = "icon",
			widget = wibox.widget.imagebox,
			halign = "center",
			valign = "center",
		},
		margins = dpi(5),
		widget = wibox.container.margin,
	}

	local indicator = {
		{
			id = "indicator",
			shape = utils.rrect(utils.dpi(15)),
			forced_height = dpi(3),
			bg = bful.tasklist_bg_normal_indicator,
			widget = wibox.container.background,
		},
		halign = "center",
		valign = "bottom",
		widget = wibox.container.place,
	}

	mytasklist.widget_template = {
		{
			nil,
			icon,
			indicator,
			forced_width = dpi(55),
			forced_height = dpi(55),
			layout = wibox.layout.align.vertical,
		},
		id = "bg_role",
		widget = wibox.container.background,
		shape = utils.rrect(dpi(10)),
		create_callback = function(self, c)
			self:get_children_by_id("icon")[1].image = utils.lookup_icon({
				utils.string.replaceWithTable(c.class, user.ReplaceClientClassnames),
				c.class,
				"application-x-executable",
			})

			local child_indicator = self:get_children_by_id("indicator")[1]
			local bg_container = self:get_children_by_id("bg_role")[1]

			local size_anim = rubato.timed({
				pos = dpi(5),
				duration = 2 / 10,
				subscribed = function(i)
					child_indicator.forced_width = i
				end,
			})

			local color_anim = rubato.timed({
				pos = 0,
				duration = 2 / 10,
				subscribed = function(i)
					bg_container.bg = color.utils.rgba_to_hex(a_to_n(i))
				end,
			})

			self.update = function()
				if c.active then
					child_indicator.bg = bful.border_color_active
					size_anim.target = dpi(20)
					color_anim.target = 1
				elseif c.minimized then
					child_indicator.bg = bful.border_color_normal
					size_anim.target = dpi(15)
					color_anim.target = 0
				else
					child_indicator.bg = bful.fg_minimize
					size_anim.target = dpi(5)
					color_anim.target = 0
				end
			end
			self.update()
		end,

		update_callback = function(self)
			self.update()
		end,
	}

	return mytasklist
end
