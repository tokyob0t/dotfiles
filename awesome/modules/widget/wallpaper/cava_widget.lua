local utils = require("utils.init")
local cairo = utils.cairo
local bful = require("beautiful")
local user = require("user")
local gears = require("gears")
local awful = require("awful")

---@type wibox
local wibox = require("wibox")
local cter = wibox.container
local widget = wibox.widget

local set_source = function(cr, height, colors, offset)
	offset = offset or 0
	if #colors > 1 then
		local pat = cairo.Pattern.create_linear(0.0, height * offset, 0.0, height + height * offset)

		utils.table.foreach(colors, function(col, i)
			pat:add_color_stop_rgba((1 / (#colors - 1)) * (i - 1), unpack(col))
			return col
		end)

		cr:set_source(pat)
	else
		cr:set_source_rgba(unpack(colors[1]))
	end
end

local wave = function(sample, cr, width, height, colors, fill, thickness)
	set_source(cr, height, colors)
	local ls = #sample
	cr:move_to(0, (1.0 - sample[1]) * height)
	for i = 1, ls - 1 do
		local height_diff = sample[i] - sample[i + 1]
		cr:rel_curve_to(
			width / (ls - 1) * 0.5,
			0.0,
			width / (ls - 1) * 0.5,
			height_diff * height,
			width / (ls - 1),
			height_diff * height
		)
	end
	if fill then
		cr:line_to(width, height)
		cr:line_to(0, height)
		cr:fill()
	else
		cr:set_line_width(thickness)
		cr:stroke()
	end
end

local cava_widget = widget({
	fit = function(_, _, width, height)
		return width, height
	end,
	draw = function(self, _, cr, width, height)
		cr:set_operator(cairo.Operator.CLEAR)
		cr:set_operator(cairo.Operator.OVER)

		local colors = utils.table.map(self.colors, function(c)
			local r, g, b, a = gears.color.parse_color(c)
			return { r, g, b, a }
		end)

		wave(self.values, cr, width, height, colors, true, 5)
	end,
	colors = { user.Colors.base0F, user.Colors.base0E },
	values = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	layout = widget.base.make_widget,
})

bash.popen(string.format("cava -p %s.config/cava/stdout_config", user.Home), function(args)
	local _args = {}
	local changed = false

	for val in args:gmatch("[^;]+") do
		table.insert(_args, tonumber(val) / 655.35)
	end

	for index, value in ipairs(_args) do
		if cava_widget.values[index] ~= value then
			changed = true
			break
		end
	end

	---@type screen
	local s = awful.screen.focused()
	---@param c client
	if changed and not utils.table.any(s.clients, function(c)
		return c.active
	end) then
		changed = false
		cava_widget.values = _args
		return cava_widget:emit_signal("widget::redraw_needed")
	end
end)

return function(s)
	return {
		cava_widget,
		bg = bful.bg_normal,
		widget = cter.background,
	}
end
