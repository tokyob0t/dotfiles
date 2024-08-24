local _USER = {}
local colorscheme = require("colorschemes")
local gears = require("gears")

-- Awesome

---@type number | 16 | 32 | 64 | 128 | 256 | 512
_USER.AwmIconSize = 512
_USER.IconTheme = "MoreWaita"
_USER.Wallpaper = "/home/tokyob0t/Pictures/Wallpapers/anime_girl_car.png"
_USER.IconFolder = "/home/tokyob0t/.config/awesome/theme/icons"
_USER.Colors = colorscheme.oxocarbon

_USER.FloatingOnTop = false
_USER.CursorFollowFocus = true
_USER.FocusFollowCursor = true
_USER.RaiseOnFocus = false
_USER.FocusOnSwitchTag = true

_USER.Gaps = dpi(5)
_USER.GapsWhenSingle = false
_USER.BorderWidth = dpi(2.5)
_USER.ClientRoundness = 0 -- Zero cuz picom

_USER.Tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

_USER.Layouts = {
	"floating",
	"dwindle",
	"tile",
	"tile_left",
	"tile_bottom",
	"tile_top",
	"fair_vertical",
	"fair_horizontal",
	"spiral",
	"max",
	"fullscreen",
	"magnifier",
	"corner",
}

_USER.ExcludedLauncherApps = {
	"AppControl",
	"Steam Linux Runtime 3.0",
	"Proton Experimental",
	"Proton BattleEye Runtime",
}

_USER.ExcludedTitlebars = {
	byTitle = {},
	byName = {},
	byClassName = {
		"blackbox",
		"resources",
		"org.gnome.Nautilus",
		"com.github.johnfactotum.Foliate",
		"icon-library",
		"gnome-control-center",
		"gtk4-icon-browser",
		"gnome-calculator",
		"gnome-font-viewer",
		"gnome-text-editor",
		"cartridges",
		"dissent",
		"bottles",
		"Lutris",
		"cambalache",
		"overskride",
		"zenity",
		"Gnome-disks",
		"secrets",
		"gradience",
		"kooha",
	},
	byRole = {},
	byType = {},
}

_USER.ForceTitlebars = {
	byTitle = {},
	byName = {},
	byClassName = {},
	byRole = {},
	byType = { "normal", "dialog" },
}

_USER.ForceFloating = {
	byTitle = { "copyq", "pinentry" },
	byName = { "Event Tester", "Media viewer" },
	byClassName = {
		"Arandr",
		"Blueman-manager",
		"Gpick",
		"Kruler",
		"Sxiv",
		"Tor Browser",
		"Wpa_gui",
		"veromix",
		"xtightvncviewer",
		"cs2",
	},
	byRole = {
		"AlarmWindow",
		"ConfigManager",
		"pop-up",
	},
	byType = { "dialog" },
}

-- ModKeys

_USER.ShiftKey = "Shift"
_USER.CtrlKey = "Control"
_USER.AltKey = "Mod1"
_USER.ModKey = "Mod4"

-- Apps

_USER.Terminal = "wezterm"
_USER.Editor = "nvim"
_USER.EditorCmd = _USER.Terminal .. " -e " .. _USER.Editor
_USER.Browser = "microsoft-edge-dev"
_USER.FileManager = "nautilus --new-window"

-- Env

_USER.Home = os.getenv("HOME") .. "/"
_USER.Documents = _USER.Home .. "Documents/"
_USER.Desktop = _USER.Home .. "Desktop/"
_USER.Screenshots = _USER.Home .. "Pictures/Screenshots/"
_USER.LocalBin = _USER.Home .. ".local/bin/"
_USER.AwmDir = gears.filesystem.get_configuration_dir()

-- Other

_USER.ReplaceClientClassnames = {
	PrismLauncher = "org.prismlauncher.PrismLauncher",
	["org.wezfurlong.wezterm"] = "org.wezfurlong.Wezterm",
	["Microsoft-edge-dev"] = "Microsoft Edge",
	-- Gtk/Gnome apps
	secrets = "org.gnome.World.Secrets",
	resources = "net.nokyan.Resources.Devel",
	blackbox = "com.raggesilver.BlackBox",
	cartridges = "page.kramo.Cartridges",
	bottles = "com.usebottles.Bottles",
	Lutris = "net.lutris.Lutris",
	cambalache = "ar.xjuan.Cambalache",
	overskride = "io.github.kaii_lb.Overskride",
	gradience = "com.github.GradienceTeam.Gradience",
	kooha = "io.github.seadve.Kooha",
	["gtk4-icon-browser"] = "org.gtk.IconBrowser",
	["icon-library"] = "org.gnome.design.IconLibrary",
	["gnome-control-center"] = "org.gnome.Settings",
	["gnome-calculator"] = "org.gnome.Calculator",
	["gnome-font-viewer"] = "org.gnome.FontViewer",
	["Gnome-disks"] = "org.gnome.DiskUtility",
	["gnome-text-editor"] = "org.gnome.TextEditor",
	-- Other
	["Terraria.bin.x86_64"] = "Terraria",
	["notify-send"] = "Awesome",
	["Nwg-look"] = "Nwg Look",
	Altus = "WhatsApp",
	TelegramDesktop = "org.telegram.Desktop",
	KotatogramDesktop = "io.github.Kotatogram",
}

_USER.ReplaceClientNames = {
	["Microsoft-edge-dev"] = "Web Broser",
	["gnome-font-viewer"] = "Font Viewer",
	imv = "Image Viewer",
	["Nwg-look"] = "GTK+ Settings",
	Altus = "WhatsApp Messenger",
	cambalache = "Cambalache",
	overskride = "Overskride",
	["Gnome-disks"] = "Gnome Disks",
	["gnome-text-editor"] = "Text Editor",
	["com.github.johnfactotum.Foliate"] = "Read books",
	TelegramDesktop = "Telegram Desktop",
}

_USER.ScreenshotApps = {
	"Screenshot",
	"Flameshot gui",
}

_USER.EnableStartupCMDS = true
_USER.StartupCMDS = {
	"powerprofilesctl set performance",
	[[bash -c "xinput set-prop $(xinput | grep -i touchpad | grep -oP 'id=\K\d+') 318 1"]], -- Natural Scroll
	"setxkbmap latam",
	"/usr/lib/xdg-desktop-portal-gnome &",
	"copyq --start-server",
	--"bluetoothctl power off",
	--"picom -b",
}

return _USER
