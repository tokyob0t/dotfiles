--TODO: Add ActivateResult to SearchProviderWidget

local App = astal.App

local Apps = astal.require("AstalApps")
local map = require("lua.lib").map

local apps = Apps.Apps({
	include_entry = true,
	include_executable = true,
})

local AppItem = function(app)
	local name = Widget.Label({
		label = app.name,
		class_name = "name",
		xalign = 0,
	})

	local description

	if app.description and #app.description > 1 then
		description = Widget.Label({
			label = app.description,
			class_name = "description",
			xalign = 0,
			ellipsize = "END",
			max_width_chars = 30,
		})
	end

	return Widget.Button({
		class_name = "flat app-item",
		valign = "START",
		on_key_press_event = function(_, event)
			if event.keyval == Gdk.KEY_Return then
				app:launch()
				astal.exec_async("astal -i astal-lua -t launcher")
			end
		end,
		Widget.Box({
			spacing = 10,
			Widget.Icon({ icon = lookup_icon({ app.icon_name, "application-x-executable" }) }),
			Widget.Box({
				spacing = 10,
				name,
				ternary(
					description,
					Widget.Icon({ icon = "dot-symbolic", class_name = "symbolic", valign = "CENTER" })
				),
				description,
			}),
		}),
	})
end

return function()
	local max_items = 10
	local widget_table = {}
	local app_query = Variable("")
	local app_list = Widget.Box({
		orientation = "VERTICAL",
		halign = "CENTER",
		class_name = "apps-container",
		bind(apps, "list"):as(function(list)
			widget_table = {}

			table.sort(list, function(a, b)
				return a.name < b.name
			end)

			return map(list, function(app)
				local widget = Widget.GtkRevealer({
					transition_type = "SLIDE_UP",
					valign = "START",
					AppItem(app),
				})
				widget_table[widget] = app
				return widget
			end)
		end),
	})
	return {
		launch_first = function()
			for _, widget in ipairs(app_list.children) do
				if widget.reveal_child then
					return widget_table[widget]:launch()
				end
			end
		end,
		filter = function(query)
			if query then
				local i = 0
				for _, item in ipairs(app_list.children) do
					local app = widget_table[item]
					local kwords = string.lower(table.concat({ app.name, app.description }, " "))

					if query == "" or i >= max_items then
						item.reveal_child = false
					elseif string.find(kwords, query, 1, true) then
						item.reveal_child = true
						i = i + 1
					else
						item.reveal_child = false
					end
				end
				return app_query:set(string.lower(query))
			end
		end,
		item_list = app_list,
	}
end
