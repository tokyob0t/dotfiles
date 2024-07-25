local ruled = require("ruled")
local awful = require("awful")
local user = require("user")

ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	})

	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			type = user.ForceFloating.byType,
			instance = user.ForceFloating.byTitle,
			class = user.ForceFloating.byClassName,
			name = user.ForceFloating.byName,
			role = user.ForceFloating.byRole,
		},
		properties = { floating = true },
	})

	ruled.client.append_rule({
		id = "titlebars",
		rule_any = {
			type = user.ForceTitlebars.byType,
			instance = user.ForceTitlebars.byTitle,
			class = user.ForceTitlebars.byClassName,
			name = user.ForceTitlebars.byName,
			role = user.ForceTitlebars.byRole,
		},
		properties = { titlebars_enabled = true },
	})
end)
