local wezterm = require("wezterm")
local config = {}

config.color_scheme = "Oxocarbon Dark"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.default_cursor_style = "BlinkingBlock"
config.window_close_confirmation = "NeverPrompt"
config.animation_fps = 144
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Constant"
config.font_size = 11.2
config.font = wezterm.font("Fira Code Nerd Font", {
	weight = "Medium",
	italic = false,
})

config.window_padding = {
	left = "2cell",
	right = "2cell",
	top = "1cell",
	bottom = "1cell",
}

return config
