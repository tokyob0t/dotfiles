local any = require("lua.lib").any
--[[
<node>
  <interface name="org.gnome.Shell.SearchProvider2">

    <method name="GetInitialResultSet">
      <arg type="as" name="terms" direction="in" />
      <arg type="as" name="results" direction="out" />
    </method>

    <method name="GetSubsearchResultSet">
      <arg type="as" name="previous_results" direction="in" />
      <arg type="as" name="terms" direction="in" />
      <arg type="as" name="results" direction="out" />
    </method>

    <method name="GetResultMetas">
      <arg type="as" name="identifiers" direction="in" />
      <arg type="aa{sv}" name="metas" direction="out" />
    </method>

    <method name="ActivateResult">
      <arg type="s" name="identifier" direction="in" />
      <arg type="as" name="terms" direction="in" />
      <arg type="u" name="timestamp" direction="in" />
    </method>

    <method name="LaunchSearch">
      <arg type="as" name="terms" direction="in" />
      <arg type="u" name="timestamp" direction="in" />
    </method>

  </interface>
</node>
]]

---@alias icon-data {[1]:number, [2]:number, [3]:number, [4]: boolean, [5]: number, [6]:number, [7]: number[]}
---@alias meta { id: string, name: string, description: string, icon: string, icon_data: icon-data, gicon?: unknown, clipboard_text?: string}

local decode_vcontainer
decode_vcontainer = function(vcontainer)
	if not vcontainer then
		return {}
	end

	local tb = {}
	local children_count = vcontainer:n_children()

	for i = 0, children_count - 1 do
		local variant = vcontainer:get_child_value(i)
		local value

		if variant:is_container() then
			value = variant:get_data_as_bytes()
		else
			value = variant.value
		end

		table.insert(tb, value)
	end

	return tb
end

local get_vardictvalue = function(vardict, k)
	for key, value in vardict:pairs() do
		if key == k then
			if value:is_container() then
				return decode_vcontainer(value)
			else
				return value.value
			end
		end
	end
end

---@class SearchProvider
---@field name string
---@field obj string
---@field iface string
local SearchProvider = {}

SearchProvider.new = function(name, obj, iface)
	local self = setmetatable({}, { __index = SearchProvider })
	self.name = name
	self.obj = obj
	self.iface = iface
	return self
end

---@param identifier string
---@param terms string[]
---@param timestamp number
---@param callback? fun(tb: table)
SearchProvider.ActivateResult = function(self, identifier, terms, timestamp, callback)
	callback = callback or function() end
	return GlobalBus:call(
		self.name,
		self.obj,
		self.iface,
		"ActivateResult",
		GLib.Variant.new_tuple({ GLib.Variant.new_strv(identifier), GLib.Variant.new("(as)", terms) }),
		GLib.VariantType.new("(aa{sv})"),
		Gio.DBusCallFlags.NONE,
		-1,
		nil,
		function(_, task)
			local tb = {}
			local result = GlobalBus:call_finish(task)

			if result then
				for _, value in result.value[1]:ipairs() do
					table.insert(tb, value)
				end

				return callback(tb)
			end
		end
	)
end

---@param terms string[]
---@param callback fun(result: string[])
SearchProvider.GetInitialResultSet = function(self, terms, callback)
	return GlobalBus:call(
		self.name,
		self.obj,
		self.iface,
		"GetInitialResultSet",
		GLib.Variant.new_tuple({ GLib.Variant.new_strv(terms) }),
		GLib.VariantType.new("(as)"),
		Gio.DBusCallFlags.NONE,
		-1,
		nil,
		function(_, task)
			local tb = {}
			local result = GlobalBus:call_finish(task)

			if result then
				for _, value in result.value[1]:ipairs() do
					table.insert(tb, value)
				end

				return callback(tb)
			end
		end
	)
end

---@param results string[]
---@param callback fun(metas: meta[])
SearchProvider.GetResultMetas = function(self, results, callback)
	return GlobalBus:call(
		self.name,
		self.obj,
		self.iface,
		"GetResultMetas",
		GLib.Variant.new_tuple({ GLib.Variant.new_strv(results) }),
		GLib.VariantType.new("(aa{sv})"),
		Gio.DBusCallFlags.NONE,
		-1,
		nil,
		function(_, task)
			---@type meta[]
			local tb = {}
			local result = GlobalBus:call_finish(task)

			if result then
				local array = result.value[1]
				for i = 0, array:n_children() - 1 do
					local vardict = array:get_child_value(i)

					table.insert(tb, {
						id = get_vardictvalue(vardict, "id"),
						name = get_vardictvalue(vardict, "name"),
						description = get_vardictvalue(vardict, "description"),
						icon = get_vardictvalue(vardict, "icon"),
						icon_data = get_vardictvalue(vardict, "icon-data"),
						gicon = get_vardictvalue(vardict, "gicon"),
						clipboard_text = get_vardictvalue(vardict, "clipboardText"),
					})
				end

				return callback(tb)
			end
		end
	)
end

---@class SearchProviderWidget
---@field title string
---@field icon_name string
---@field max_items number
---@field provider SearchProvider
---@field icon_list unknown
local SearchProviderWidget = {}

---@param title string
---@param icon_name string
---@param max_items number
---@param provider SearchProvider
SearchProviderWidget.new = function(title, icon_name, max_items, provider)
	local self = setmetatable({}, { __index = SearchProviderWidget })
	self.title = title
	self.icon_name = icon_name
	self.max_items = max_items
	self.provider = provider

	self.icon_list = Widget.Box({
		orientation = "VERTICAL",
		setup = function(this)
			for _ = 1, self.max_items do
				local icon = Widget.Icon({})
				local label = Widget.Label({ max_width_chars = 30, ellipsize = "END" })
				local desc = Widget.Label({ max_width_chars = 50, ellipsize = "END", class_name = "description" })
				this:add(Widget.GtkRevealer({
					reveal_child = bind(label, "label"):as(function(v)
						return v and #v > 0
					end),
					Widget.Button({
						valign = "START",
						halign = "START",
						Widget.Box({ spacing = 10, icon, label, desc }),
					}),
				}))
			end
		end,
	})
	self.item_list = Widget.GtkRevealer({
		transition_type = "SLIDE_UP",
		setup = function(this)
			for _, value in ipairs(self.icon_list.children) do
				this:hook(value, "notify::reveal-child", function()
					this.reveal_child = any(self.icon_list.children, function(c)
						return c.reveal_child
					end)
				end)
			end
		end,
		Widget.Box({
			class_name = "other-container",
			spacing = 5,
			Widget.Box({
				spacing = 10,
				class_name = "app-widget",
				valign = "START",
				Widget.Icon({ icon = self.icon_name }),
				Widget.Label({ label = self.title }),
			}),
			self.icon_list,
		}),
	})
	return self
end

SearchProviderWidget.UpdateLauncherItem = function(self, revealer, data)
	local button = revealer:get_children()[1]
	local box = button:get_children()[1]
	local icon, label, desc = table.unpack(box:get_children())

	if data and data.name then
		label.label = data.name
		desc.label = data.description or ""
		local hints = data.icon_data

		if hints and #hints > 0 then
			icon.pixbuf = GdkPixbuf.Pixbuf.new_from_bytes(
				hints[7],
				GdkPixbuf.Colorspace.RGB,
				hints[4],
				hints[5],
				hints[1],
				hints[2],
				hints[3]
			)
		elseif data.icon then
			local filetype, bytes = table.unpack(data.icon)
		end
	else
		label.label = ""
		desc.label = ""
	end
end
SearchProviderWidget.filter = function(self, query)
	if query and #query > 0 then
		local terms = {}

		for word in string.gmatch(query, "%S+") do
			table.insert(terms, word)
		end

		return self.provider:GetInitialResultSet(terms, function(result)
			if result and #result > 0 then
				local tb = {}

				for i = 1, self.max_items do
					if result[i] ~= nil then
						tb[i] = result[i]
					else
						break
					end
				end

				self.provider:GetResultMetas(tb, function(metas)
					if metas and #metas > 0 then
						for index, value in ipairs(self.icon_list.children) do
							self:UpdateLauncherItem(value, metas[index])
						end
					end
				end)
			end
		end)
	else
		for index, value in ipairs(self.icon_list.children) do
			self:UpdateLauncherItem(value, {})
		end
	end
end

return { SearchProvider, SearchProviderWidget }
