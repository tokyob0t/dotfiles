local awful = require("awful")
---@type theme
local bful = require("beautiful")
local user = require("user")

local rubato = require("lib.rubato")
local color = require("lib.color")
local utils = require("utils.init")
---@type wibox
local wibox = require("wibox")
local cter = wibox.container
local widget = wibox.widget

local get_color = function(col)
	local my_color = {}
	my_color.r, my_color.g, my_color.b = color.utils.hex_to_rgba(col)
	my_color = color.color(my_color)
	return my_color
end

local normal_bg_color = get_color(bful.tasklist_bg_normal)
local active_bg_color = get_color(bful.tasklist_bg_focus)
local activebg_to_normalbg = color.transition(normal_bg_color, active_bg_color, 0)

return function(screen)
	local mytasklist = awful.widget.tasklist({
		screen = screen,
		filter = awful.widget.tasklist.filter.alltags,
		style = { shape = utils.rrect(dpi(10)) },
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
		id = "icon",
		widget = widget.imagebox,
		forced_width = dpi(37),
		forced_height = dpi(37),
	}
	icon.posx = (dpi(55) / 2) - (icon.forced_width / 2)
	icon.posy = (dpi(55) / 2) - (icon.forced_height / 2) - dpi(3)
	icon.point = { x = icon.posx, y = icon.posy }

	local indicator = {
		{
			id = "indicator",
			shape = utils.rrect(dpi(15)),
			forced_height = dpi(3),
			bg = bful.tasklist_fg_normal,
			widget = cter.background,
		},
		halign = "center",
		valign = "bottom",
		widget = cter.place,
	}

	mytasklist.widget_template = {
		{
			{
				icon,
				layout = wibox.layout.manual,
			},
			indicator,
			forced_width = dpi(55),
			forced_height = dpi(55),
			layout = wibox.layout.stack,
		},
		id = "bg_role",
		widget = cter.background,
		shape = utils.rrect(dpi(10)),
		---@param c client
		create_callback = function(self, c)
			self:get_children_by_id("icon")[1].image = utils.lookup_icon({
				utils.string.replace_with_table(c.class, user.ReplaceClientClassnames),
				c.class,
				c.icon_name,
			}) or c.icon or utils.lookup_icon({ icon_name = "application-x-executable" })

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
					bg_container.bg = color.utils.rgba_to_hex(activebg_to_normalbg(i))
				end,
			})

			self.update = function()
				if c.active then
					child_indicator.bg = bful.tasklist_fg_focus
					size_anim.target = dpi(20)
					color_anim.target = 1
				elseif c.minimized then
					child_indicator.bg = bful.tasklist_fg_minimize
					size_anim.target = dpi(15)
					color_anim.target = 0
				else
					child_indicator.bg = bful.tasklist_fg_normal
					size_anim.target = dpi(8)
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
