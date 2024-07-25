local bful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local utils = require("utils.init")

local dpi = utils.dpi

local function taglist(screen)
	local mytaglist = awful.widget.taglist({
		screen = screen,
		filter = awful.widget.taglist.filter.all,
		layout = {
			spacing = dpi(5),
			halign = "center",
			valign = "center",
			layout = wibox.layout.fixed.horizontal,
		},
		style = { shape = utils.rrect(utils.dpi(50)) },
	})

	mytaglist.buttons = {
		awful.button({}, 1, function(t)
			t:view_only()
		end),
	}

	mytaglist.widget_template = {
		{
			text = "",
			widget = wibox.widget.textbox,
		},
		id = "background_role",
		forced_height = dpi(20),
		forced_width = dpi(60),
		widget = wibox.container.background,
		create_callback = function(self, tag)
			self.update = function()
				if tag.selected then
					self:get_children_by_id("background_role")[1].forced_width = dpi(60)
				elseif #tag:clients() > 0 then
					self:get_children_by_id("background_role")[1].forced_width = dpi(45)
				else
					self:get_children_by_id("background_role")[1].forced_width = dpi(30)
				end
			end
			self.update()
		end,
		update_callback = function(self)
			self.update()
		end,
	}
	return {
		{
			{
				mytaglist,
				widget = wibox.container.place,
			},
			top = dpi(10),
			bottom = dpi(10),
			left = dpi(20),
			right = dpi(20),
			widget = wibox.container.margin,
		},
		shape = utils.rrect(utils.dpi(50)),
		bg = bful.taglist_bg_normal,
		widget = wibox.container.background,
	}
end

return taglist
