local bful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local utils = require("utils.init")
local rubato = require("lib.rubato")
local widget = wibox.widget
local cter = wibox.container

---@param s screen
return function(s)
	local mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = {
			spacing = dpi(5),
			halign = "center",
			valign = "center",
			layout = wibox.layout.fixed.horizontal,
		},
		style = { shape = utils.rrect(dpi(50)) },
		buttons = {
			awful.button({}, 1, function(t)
				t:view_only()
			end),
		},
	})

	mytaglist.widget_template = {
		{
			text = "",
			widget = widget.textbox,
		},
		id = "background_role",
		widget = cter.background,
		forced_height = dpi(5),
		forced_width = dpi(50),
		create_callback = function(self, tag)
			local bg_role = self:get_children_by_id("background_role")[1]

			self.anim = rubato.timed({
				pos = 50,
				duration = 0.2,
				subscribed = function(p)
					bg_role.forced_width = p
				end,
			})

			self.update = function()
				if tag.selected then
					self.anim.target = dpi(50)
				elseif #tag:clients() > 0 then
					self.anim.target = dpi(40)
				else
					self.anim.target = dpi(30)
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
				widget = cter.place,
			},
			top = dpi(10),
			bottom = dpi(10),
			left = dpi(20),
			right = dpi(20),
			widget = cter.margin,
		},
		bg = bful.taglist_bg_normal,
		widget = cter.background,
		buttons = {
			awful.button({}, 4, function()
				awful.tag.viewprev(s)
			end),
			awful.button({}, 5, function()
				awful.tag.viewnext(s)
			end),
		},
	}
end
