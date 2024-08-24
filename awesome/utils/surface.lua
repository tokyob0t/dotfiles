local lgi = require("lgi")

local cairo = lgi.require("cairo", "1.0")
local Rsvg = lgi.require("Rsvg", "2.0")
---@type gears
local gears = require("gears")
local color = require("lib.color")

---@class utils.surface
local _S = {}

---Fill non-transparent area of an image with a given color.
---@param image string
---@param new_color string
---@return gears.surface | nil
_S.recolor_image = function(image, new_color, width, height)
	if type(image) == "string" then
		width = width or 16
		height = height or 16
		local handle = Rsvg.Handle.new_from_file(image)
		local dimensions = handle:get_dimensions()

		local surface = cairo.ImageSurface.create(cairo.Format.ARGB32, width, height)
		local cr = cairo.Context(surface)

		cr:scale(width / dimensions.width, height / dimensions.height)

		handle:render_cairo(cr)

		return gears.color.recolor_image(surface, new_color)
	else
		return gears.color.recolor_image(image, new_color)
	end
end

---@param width number
---@param height number
---@param surface gears.surface
---@return gears.surface
_S.resize = function(width, height, surface)
	local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
	local cr = cairo.Context(out_surf)

	local orig_width = surface:get_width()
	local orig_height = surface:get_height()

	local scale_x = width / orig_width
	local scale_y = height / orig_height
	cr:scale(scale_x, scale_y)
	cr:set_source_surface(surface, 0, 0)
	cr.operator = cairo.Operator.SOURCE
	cr:paint()

	return out_surf
end

---@param image gears.surface | string
---@return string
_S.dominant_color = function(image)
	local surface = image

	if type(surface) == "string" then
		return _S.dominant_color(gears.surface.load_uncached(surface))
	end

	local width, height = gears.surface.get_size(surface)

	require("naughty").notify({ message = tostring(width) .. "x" .. tostring(height) })
	local color_count = {}

	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local pixel = surface:get_pixel(x, y)
			local r, g, b, _ = gears.color.parse_color(pixel)
			--local hex_color = string.format("#%02x%02x%02x", r * 255, g * 255, b * 255)

			local hex_color = color.utils.rgba_to_hex(color.color({ r = r, g = g, b = b }))

			color_count[hex_color] = (color_count[hex_color] or 0) + 1
		end
	end

	local dominant_color, max_count = nil, 0

	for col, count in pairs(color_count) do
		if count > max_count then
			dominant_color = col
			max_count = count
		end
	end

	return dominant_color
end

---@param radius  number
---@param surface gears.surface
---@return gears.surface
_S.round = function(radius, surface)
	local width = surface:get_width()
	local height = surface:get_height()

	local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
	local cr = cairo.Context(out_surf)
	cr:arc(radius, radius, radius, math.pi, 3 * math.pi / 2)
	cr:arc(width - radius, radius, radius, 3 * math.pi / 2, 0)
	cr:arc(width - radius, height - radius, radius, 0, math.pi / 2)
	cr:arc(radius, height - radius, radius, math.pi / 2, math.pi)
	cr:close_path()

	cr:clip()

	cr:set_source_surface(surface, 0, 0)
	cr.operator = cairo.Operator.SOURCE
	cr:paint()

	return out_surf
end

return _S
