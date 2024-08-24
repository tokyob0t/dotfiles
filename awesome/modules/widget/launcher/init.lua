local user = require("user")
local fzy = require("lib.fzy")
local utils = require("utils.init")
local awful = require("awful")
local wibox = require("wibox")

local cter = wibox.container
local widget = wibox.widget

---@type theme
local bful = require("beautiful")

local rubato = require("lib.rubato")
local applications = require("services.applications")

---@type App[]
local all_apps = utils.table.filter(
	applications.get_all(),
	---@param app App
	function(app)
		for _, value in ipairs(user.ExcludedLauncherApps) do
			if app:match(value) then
				return false
			end
		end
		return true
	end
)

table.sort(all_apps, function(a, b)
	return string.lower(a.name) < string.lower(b.name)
end)

local smol_icon = function(name)
	return {
		image = utils.lookup_icon({
			icon_name = name,
			size = 32,
			recolor = bful.fg_normal,
		}),
		forced_height = dpi(16),
		forced_width = dpi(16),
		widget = widget.imagebox,
		valign = "center",
	}
end

---@param app App
local app_item = function(app)
	local a_name, a_comment

	a_name = app.name
	a_name = ternary(utils.string.has_capital(app.name), app.name, utils.string.capitalize(app.name))
	a_comment = app.comment

	a_name = string.gsub(a_name, "\n", "")
	a_comment = string.gsub(a_comment, "\n", "")

	a_name = string.format(
		"<span font_weight='600' fgcolor='%s' font_family='Segoe UI Variable' size='%dpt'>%s</span>",
		bful.colorscheme.base04,
		dpi(10),
		a_name
	)

	a_comment = string.format(
		"<span font_weight='500' fgcolor='%s' font_family='Segoe UI Variable Light' size='%dpt'>%s</span>",
		bful.colorscheme.base03,
		dpi(9),
		a_comment
	)
	return {
		{
			{
				{
					image = utils.lookup_icon({
						icon_name = { app.icon_name, "application-x-executable" },
						size = 32,
					}),
					widget = widget.imagebox,
					forced_width = dpi(32),
					forced_height = dpi(32),
				},
				ternary(string.len(app.comment) > 2 and app.comment ~= "Play this game on Steam", {
					{ widget = widget.textbox, markup = a_name },
					{ widget = widget.textbox, markup = a_comment },
					layout = wibox.layout.fixed.vertical,
				}, {
					{ widget = widget.textbox, markup = a_name, valign = "center" },
					layout = wibox.layout.flex.vertical,
				}),
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),
			},
			widget = cter.margin,
			margins = dpi(10),
		},
		shape = utils.rrect(dpi(10)),
		widget = cter.background,
		app = app,
	}
end

local function gen_app_list(q)
	--- score, keywords, comment, app-name
	local s, k, c, n, my_app_widget
	local filtered_apps = {}
	q = string.lower(q or "")

	for _, value in ipairs(all_apps) do
		k = string.gsub(string.lower(value.keywords), "[^%w%s]", " ")
		c = string.gsub(string.lower(value.comment), "[^%w%s]", " ")

		if q ~= "" then
			if value:match(q) then
				s = fzy.score(q, k) + ternary(c ~= "play this game on steam", 0, -1)
			elseif fzy.has_match(q, k) then
				s = fzy.score(q, k) - 3
			else
				s = 0
			end
		else
			s = 1
		end

		if #filtered_apps < 8 and s > 0 then
			my_app_widget = app_item(value)
			my_app_widget.score = s
			table.insert(filtered_apps, my_app_widget)
		end
	end

	if q ~= "" then
		table.sort(filtered_apps, function(a, b)
			return a.score > b.score
		end)
		if #filtered_apps >= 1 then
			filtered_apps[1].bg = bful.bg_focus
		end
	end

	filtered_apps.widget = cter.place
	filtered_apps.layout = wibox.layout.flex.vertical

	collectgarbage("collect")
	return filtered_apps
end

return function(s)
	local l_height, l_width, startpos, endpos, d_in, d_out, prompt

	d_in, d_out = 0.3, 0.2

	-- Launcher height/width
	l_height, l_width = dpi(500), dpi(400)
	startpos = (s.geometry.height - l_height) / 2 + dpi(100)
	endpos = (s.geometry.height - l_height) / 2 - dpi(50)
	prompt = widget({ id = "prompt", widget = widget.textbox })

	local app_prompt_thing = {
		{
			{
				smol_icon("system-search-symbolic"),
				{
					prompt,
					widget = cter.margin,
					left = dpi(10),
					right = dpi(10),
				},
				smol_icon("entry-clear-symbolic"),
				forced_height = dpi(30),
				spacing = dpi(10),
				layout = wibox.layout.align.horizontal,
			},
			left = dpi(10),
			right = dpi(10),
			widget = cter.margin,
		},
		bg = bful.bg_focus,
		shape = utils.rrect(dpi(10)),
		widget = cter.background,
	}

	local app_list_thing = {
		gen_app_list(),
		id = "scroll",
		layout = wibox.layout.fixed.vertical,
	}

	local app_launcher = wibox({
		screen = s,
		y = startpos,
		x = (s.geometry.width - l_width) / 2,
		width = l_width,
		height = l_height,
		ontop = true,
		visible = false,
		widget = {
			{
				{
					app_prompt_thing,
					app_list_thing,
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(10),
				},
				margins = dpi(10),
				widget = cter.margin,
			},
			widget = cter.background,
		},
	})

	local anim = {
		position = rubato.timed({
			pos = startpos,
			duration = d_in,
			subscribed = function(p)
				app_launcher.y = p
			end,
		}),
		opacity = rubato.timed({
			pos = 0,
			duration = d_in,
			subscribed = function(p)
				app_launcher.opacity = p
			end,
		}),
	}

	app_launcher.set_visible = function(self, visible)
		if self.visible == visible then
			return
		end

		if visible then
			self.drawin.visible = true
			anim.opacity.duration = d_in
			anim.position.duration = d_in

			anim.opacity.target = 1
			anim.position.target = endpos
		else
			wait((d_in + d_out) / 2, function()
				self.drawin.visible = false
			end)

			anim.opacity.duration = d_out
			anim.position.duration = d_out

			anim.opacity.target = 0
			anim.position.target = startpos
		end
	end

	app_launcher:connect_signal("property::visible", function(self)
		if self.visible then
			awful.prompt.run({
				textbox = prompt,
				selectall = true,
				hooks = {
					{
						{ user.ModKey },
						"r",
						function()
							app_launcher.visible = false
						end,
					},
				},
				---@param input string
				exe_callback = function(input)
					if not input or #input == 0 then
						return
					else
						local app_item_widget = utils.table.find(
							self:get_children_by_id("scroll")[1].children,
							function()
								return true
							end
						)
						if app_item_widget then
							return app_item_widget.app:launch()
						end
					end
				end,
				changed_callback = function(input)
					self:get_children_by_id("scroll")[1].children = gen_app_list(input)
				end,
				done_callback = function()
					self:get_children_by_id("scroll")[1].children = gen_app_list()
					self.visible = false
				end,
			})
		else
			return awful.keygrabber.stop()
		end
	end)

	return app_launcher
end
