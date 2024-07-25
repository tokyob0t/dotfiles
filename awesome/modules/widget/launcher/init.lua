local user = require("user")
---@type theme
local bful = require("beautiful")
local awful = require("awful")
local wibox = require("wibox")
local rubato = require("lib.rubato")
local utils = require("utils.init")
local dpi = utils.dpi
local applications = require("utils.applications")

local all_apps = utils.table.filter(
	applications.get_all(),
	---@param app App
	function(app)
		if #user.ExcludedLauncherApps >= 1 then
			for _, value in ipairs(user.ExcludedLauncherApps) do
				if app:match(value) then
					return false
				end
			end
		else
			return true
		end
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
		widget = wibox.widget.imagebox,
		valign = "center",
	}
end

---@param app App
local app_item = function(app)
	local a_name, a_comment

	if utils.string.has_capital(app.name) then
		a_name = utils.string.markdown_to_markup(app.name) or app.name
	else
		a_name = utils.string.capitalize(utils.string.markdown_to_markup(app.name) or app.name)
	end

	a_comment = utils.string.markdown_to_markup(app.comment) or app.comment

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
					widget = wibox.widget.imagebox,
					forced_width = dpi(32),
					forced_height = dpi(32),
				},
				utils.t(string.len(app.comment) > 2, {
					{ widget = wibox.widget.textbox, markup = a_name },
					{ widget = wibox.widget.textbox, markup = a_comment },
					layout = wibox.layout.fixed.vertical,
				}, {
					{ widget = wibox.widget.textbox, markup = a_name, valign = "center" },
					layout = wibox.layout.flex.vertical,
				}),
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),
			},
			widget = wibox.container.margin,
			margins = dpi(10),
		},
		widget = wibox.container.background,
		app = app,
	}
end

local function gen_app_list(query)
	query = query or ""

	local filtered_apps = {}

	for _, value in ipairs(all_apps) do
		if value:match(query) and #filtered_apps < 7 then
			table.insert(filtered_apps, app_item(value))
		end
	end
	filtered_apps.widget = wibox.container.place
	filtered_apps.layout = wibox.layout.flex.vertical
	filtered_apps.valign = "top"

	return filtered_apps
end

return function(s)
	local l_height, l_width, startpos, endpos, d_in, d_out, prompt

	d_in, d_out = 0.3, 0.2

	-- Launcher height/width
	l_height, l_width = dpi(500), dpi(400)
	startpos = (s.geometry.height - l_height) / 2 + dpi(100)
	endpos = (s.geometry.height - l_height) / 2 - dpi(50)
	prompt = wibox.widget({ id = "prompt", widget = wibox.widget.textbox })

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
					{
						{
							{
								smol_icon("system-search-symbolic"),
								{
									prompt,
									widget = wibox.container.margin,
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
							widget = wibox.container.margin,
						},
						bg = bful.bg_focus,
						shape = utils.rrect(dpi(10)),
						widget = wibox.container.background,
					},
					{
						gen_app_list(),
						id = "scroll",
						layout = wibox.layout.fixed.vertical,
					},
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(10),
				},
				margins = dpi(10),
				widget = wibox.container.margin,
			},
			widget = wibox.container.background,
		},
	})

	app_launcher.anim = {
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
			app_launcher.anim.opacity.duration = d_in
			app_launcher.anim.position.duration = d_in

			app_launcher.anim.opacity.target = 1
			app_launcher.anim.position.target = endpos
		else
			utils.wait((d_in + d_out) / 2, function()
				self.drawin.visible = false
			end)

			app_launcher.anim.opacity.duration = d_out
			app_launcher.anim.position.duration = d_out

			app_launcher.anim.opacity.target = 0
			app_launcher.anim.position.target = startpos
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
							app_item_widget.app:launch()
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
