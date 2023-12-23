local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.window_close_confirmation = "NeverPrompt"
config.default_cursor_style = "BlinkingBlock"
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = "Oxocarbon Dark"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_ease_in = "Linear"
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
-- config.front_end = "WebGpu"
config.animation_fps = 144
-- config.front_end="OpenGL"
config.font_size = 10.2

config.window_padding = {
	left = "3cell",
	right = "3cell",
	top = "1cell",
	bottom = "1cell",
}

return config
