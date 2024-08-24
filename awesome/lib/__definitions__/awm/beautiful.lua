---@class beautiful
---@field gtk beautiful.gtk @Namespace for GTK-related functions.
---@field theme_assets beautiful.theme_assets @Namespace for theme asset generation functions.
---@field xresources beautiful.xresources @Namespace for Xresources-related functions.
---@field get fun(): table @Get the current theme.
---@field init fun(config: table): boolean|nil @Initialize the theme settings.
---@field get_font fun(name: string): lgi.Pango.FontDescription @Get a font description.
---@field get_merged_font fun(name: string, merge: table): lgi.Pango.FontDescription @Get a new font with merged attributes, based on another one.
---@field get_font_height fun(name: string): number @Get the height of a font.

---@class beautiful.gtk
---@field get_theme_variables fun(): table @Get GTK+3 theme variables from GtkStyleContext.

---@class beautiful.theme_assets
---@field taglist_squares_sel fun(size: number, fg: string) @Generate selected taglist square.
---@field taglist_squares_unsel fun(size: number, fg: string) @Generate unselected taglist square.
---@field gen_awesome_name fun(cr: lgi.cairo.Context, height: number, bg: string, fg: string, alt_fg: string) @Put Awesome WM name onto cairo surface.
---@field gen_logo fun(cr: lgi.cairo.Context, width: number, height: number, bg: string, fg: string) @Put Awesome WM logo onto cairo surface.
---@field awesome_icon fun(size: number, bg: string, fg: string) @Generate Awesome WM logo.
---@field wallpaper fun(bg: string, fg: string, alt_fg: string, s: screen) @Generate Awesome WM wallpaper.
---@field recolor_titlebar fun(theme: table, color: string, state: string, postfix: string, toggle_state: boolean): table @Recolor titlebar icons.
---@field recolor_layout fun(theme: table, color: string): table @Recolor layout icons.

---@class beautiful.xresources
---@field get_current_theme fun(): table @Get current base colorscheme from xrdb.
---@field set_dpi fun(dpi: number, s: screen) @Set DPI for a given screen (defaults to global).
---@field apply_dpi fun(size: number, s: screen): integer @Compute resulting size applying current DPI value (optionally per screen).
