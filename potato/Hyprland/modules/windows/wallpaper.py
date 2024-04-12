from PotatoWidgets import Applications, Bash, Gdk, Widget
from PotatoWidgets.Imports import Gtk

from .togglewindows import CloseAll

# from .wallpaperstuff import *

TERMS = ["kitty", "wezterm", "alacritty"]

TERM = next(i for i in Applications().get_all() if any(j in i.keywords for j in TERMS))


def DeskMenuItem(icon, name, size=0, submenu=None, onactivate=lambda x: x):
    return Widget.MenuItem(
        classname="deskmenuitem",
        onactivate=onactivate,
        children=Widget.Box(
            hexpand=True,
            size=[30, 10],
            classname="deskmenubox",
            children=[
                Widget.Box(
                    spacing=10,
                    children=[
                        Widget.Icon(
                            icon,
                            size or 16,
                            classname="icon black",
                            halign="start",
                            valign="center",
                        ),
                        Widget.Label(
                            name,
                            halign="start",
                            valign="center",
                        ),
                    ],
                ),
                (
                    Widget.Box(
                        hexpand=True,
                        halign="end",
                        children=[
                            Widget.Icon(
                                "go-next-symbolic",
                                16,
                                classname="icon black",
                                halign="end",
                                valign="center",
                            )
                        ],
                    )
                    if submenu
                    else None
                ),
            ],
        ),
        submenu=submenu,
    )


DesktopMenu = Widget.Menu(
    classname="deskmenu",
    size=[250, 0],
    children=[
        DeskMenuItem(
            "view-grid-symbolic",
            "View",
        ),
        DeskMenuItem(
            "view-list-symbolic",
            "Sort by",
        ),
        DeskMenuItem("view-refresh-symbolic", "Refresh"),
        Gtk.SeparatorMenuItem(),
        DeskMenuItem("edit-undo-symbolic", "Undo Delete"),
        DeskMenuItem(
            "zoom-in-symbolic",
            "New",
        ),
        Gtk.SeparatorMenuItem(),
        DeskMenuItem("video-display-symbolic", "Display Settings"),
        DeskMenuItem(
            "terminal",
            "Launch Terminal",
            onactivate=lambda: TERM.launch(),
        ),
        Gtk.SeparatorMenuItem(),
        DeskMenuItem(
            "system-shutdown-symbolic",
            "Power Menu",
            submenu=Widget.Menu(
                classname="deskmenu",
                children=[
                    DeskMenuItem(
                        "system-reboot-symbolic",
                        "Reboot",
                        onactivate=lambda: Bash.popen("notify-send reboot reboot"),
                    ),
                    DeskMenuItem(
                        "system-lock-screen-symbolic",
                        "Lock Session",
                        onactivate=lambda: Bash.popen("notify-send lock session"),
                    ),
                    DeskMenuItem(
                        "system-log-out-symbolic",
                        "Log Out",
                        onactivate=lambda: Bash.popen("notify-send log out"),
                    ),
                    DeskMenuItem(
                        "system-shutdown-symbolic",
                        "Shutdown",
                        onactivate=lambda: Bash.popen("notify-send shut down"),
                    ),
                ],
            ),
        ),
    ],
)


Wallpaper = Widget.Window(
    size=["100%", "100%"],
    layer="background",
    at={"bottom": -50},
    position="top left right bottom",
    namespace="Wallpaper",
    children=Widget.Box(
        classname="wallpaper",
        hexpand=True,
        vexpand=True,
        children=[
            Widget.EventBox(
                hexpand=True,
                vexpand=True,
                classname="deskmenueventbox",
                primaryhold=CloseAll,
                secondaryrelease=lambda event: (
                    CloseAll(),
                    DesktopMenu.popup_at_pointer(event),
                ),
                # children=Widget.Box(DESKTOP_ENTRIES, spacing=5, css="padding: 20px;"),
            ),
        ],
    ),
)


def ClasifEvent(event: Gdk.EventButton):
    print(event.type)
