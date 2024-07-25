local tag = tag
local client = client
local utils = require("utils.init")
local user = require("user")
local wibox = require("wibox")
local bful = require("beautiful")
local dpi = utils.dpi

local function active_class(s)
	local mytextbox = wibox.widget({
		widget = wibox.widget.textbox,
	})
	mytextbox.markup = utils.string.colorize("Desktop", bful.fg_minimize)

	client.connect_signal("property::active", function(c)
		if utils.table.any(client.get(s), function(cc)
			return cc.active
		end) then
			local className

			if c.class then
				mytextbox.visible = true
				className = utils.string.replaceWithTable(c.class, user.ReplaceClientClassnames)
				className = utils.t(utils.string.has_capital(className), className, utils.string.capitalize(className))
				mytextbox.markup = utils.string.colorize(className, bful.fg_minimize)
			else
				mytextbox.visible = false
			end
		else
			mytextbox.markup = utils.string.colorize("Desktop", bful.fg_minimize)
		end
	end)

	return mytextbox
end

local function active_name(s)
	local mytextbox = wibox.widget({
		widget = wibox.widget.textbox,
		font = "Segoe UI Variable 800 10",
		ellipsize = "end",
		forzed_width = dpi(20),
	})
	local tagSelected = 1
	local allowChange = false
	mytextbox.markup = "on Tag " .. tagSelected

	tag.connect_signal("property::selected", function(t)
		if t.selected then
			tagSelected = t.name
			if allowChange then
				mytextbox.markup = "on Tag " .. tagSelected
			end
		end
	end)

	client.connect_signal("property::active", function(c)
		if utils.table.any(client.get(s), function(cc)
			return cc.active
		end) then
			allowChange = false
			if user.ReplaceClientNames[c.class] then
				mytextbox.markup = user.ReplaceClientNames[c.class]
			else
				mytextbox.markup = c.name
			end
		else
			allowChange = true
			mytextbox.markup = "on Tag " .. tagSelected
		end
	end)

	return {
		mytextbox,
		layout = wibox.layout.fixed.horizontal,
	}
end

local function active_client(s)
	return {
		{
			active_class(s),
			active_name(s),
			layout = wibox.layout.fixed.vertical,
		},
		widget = wibox.container.place,
		valign = "center",
	}
end

return active_client
