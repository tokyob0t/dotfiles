---------------------------
-- Default awesome theme --
---------------------------

local user = require("user")
local utils = require("utils.init")
local gears = require("gears")
local color = require("lib.color")
local colorscheme = user.Colors
local theme_assets = require("beautiful.theme_assets")
local themes_path = gears.filesystem.get_configuration_dir() .. "theme/"

local get_color = function(col)
	local my_color = {}
	my_color.r, my_color.g, my_color.b = color.utils.hex_to_rgba(col)
	my_color = color.color(my_color)
	return my_color
end

---@param col1 string
---@param col2 string
---@param t number
---@return string
local mix = function(col1, col2, t)
	local col1_to_col2 = color.transition(get_color(col1), get_color(col2), 0)

	return color.utils.rgba_to_hex(col1_to_col2(t))
end

---@param col string
---@param a number
---@return string
local transparentize = function(col, a)
	local _col = get_color(col)
	_col.a = a
	return color.utils.rgba_to_hex(_col)
end

---@class theme: beautiful
local theme = {}
theme.mix = mix
theme.transparentize = transparentize

theme.colorscheme = colorscheme
theme.wallpaper = user.Wallpaper
theme.font = "Segoe UI Variable 10"

theme.bg_normal = colorscheme.base00
theme.bg_focus = colorscheme.base01
theme.bg_urgent = colorscheme.base0A
theme.bg_minimize = colorscheme.base01
theme.bg_systray = theme.bg_normal

theme.fg_normal = colorscheme.base04
theme.fg_focus = colorscheme.base06
theme.fg_urgent = colorscheme.base06
theme.fg_minimize = colorscheme.base03

theme.useless_gap = user.Gaps
theme.border_width = user.BorderWidth
theme.border_color_normal = colorscheme.base01
theme.border_color_active = colorscheme.base09
theme.border_color_marked = colorscheme.base0A

--
-- TASKLIST
--

theme.tasklist_bg_normal = colorscheme.base00
theme.tasklist_bg_focus = colorscheme.base01
theme.tasklist_bg_minimize = colorscheme.base00
theme.tasklist_bg_urgent = mix(colorscheme.base00, colorscheme.base0A, 0.3)

theme.tasklist_fg_normal = colorscheme.base02
theme.tasklist_fg_focus = colorscheme.base09
theme.tasklist_fg_minimize = colorscheme.base01
theme.tasklist_fg_urgent = mix(colorscheme.base00, colorscheme.base0A, 0.5)

-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
theme.taglist_bg_normal = colorscheme.base00
theme.taglist_bg_focus = colorscheme.base09
theme.taglist_bg_empty = colorscheme.base01
theme.taglist_bg_occupied = colorscheme.base02

-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
--local taglist_square_size = dpi(4)
--theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
--theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

---
--- NOTIFICATIONS
---

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
theme.notification_bg = colorscheme.base00
theme.notification_border_color = nil
theme.notification_border_width = 0
theme.notification_width = dpi(400)
theme.notification_height = nil
theme.notification_shape = utils.rrect(dpi(10))
theme.notification_margin = dpi(10)

---
--- CHART
---

theme.arcchart_rounded_edge = true
theme.arcchart_bg = colorscheme.base01
theme.arcchart_color = { colorscheme.base09 }

---
--- TRAY
---

theme.systray_icon_spacing = dpi(5)

theme.menu_submenu_icon = themes_path .. "submenu.png"
theme.menu_font = "Segoe UI Variable 10"
theme.menu_height = dpi(25)
theme.menu_width = dpi(150)
theme.menu_border_color = nil
theme.menu_border_width = nil
theme.menu_bg_normal = nil
theme.menu_fg_normal = nil
theme.menu_bg_focus = nil
theme.menu_fg_focus = nil

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = themes_path .. "titlebar/close_normal.png"
theme.titlebar_close_button_focus = themes_path .. "titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path .. "titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = themes_path .. "titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path .. "titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = themes_path .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = themes_path .. "titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path .. "titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = themes_path .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = themes_path .. "titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path .. "titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = themes_path .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = themes_path .. "titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path .. "titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = themes_path .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = themes_path .. "titlebar/maximized_focus_active.png"

theme.layout_fairh = utils.LayoutIcon("fairh")
theme.layout_fairv = utils.LayoutIcon("fairv")
theme.layout_floating = utils.LayoutIcon("floating")
theme.layout_magnifier = utils.LayoutIcon("magnifier")
theme.layout_max = utils.LayoutIcon("max")
theme.layout_fullscreen = utils.LayoutIcon("fullscreen")
theme.layout_tilebottom = utils.LayoutIcon("tilebottom")
theme.layout_tileleft = utils.LayoutIcon("tileleft")
theme.layout_tile = utils.LayoutIcon("tile")
theme.layout_tiletop = utils.LayoutIcon("tiletop")
theme.layout_spiral = utils.LayoutIcon("spiral")
theme.layout_dwindle = utils.LayoutIcon("dwindle")
theme.layout_cornernw = utils.LayoutIcon("cornernw")
theme.layout_cornerne = utils.LayoutIcon("cornerne")
theme.layout_cornersw = utils.LayoutIcon("cornersw")
theme.layout_cornerse = utils.LayoutIcon("cornerse")

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(user.AwmIconSize, theme.fg_focus, theme.bg_focus)
theme.icon_theme = user.IconTheme

return theme
