from PotatoWidgets import Bash, Widget, lookup_icon
from PotatoWidgets.Services import Applications
from PotatoWidgets.Services.Hyprland import HyprlandService

from ..common import ActiveWindow, ActiveWorkspaces, Window, Workspace

PINNED_APPS = [
    "blackbox",
    # "wezterm",
    "nautilus",
    "zathura",
    "obsidian",
    "neovim",
    "firefox web browser",
    "vscodium",
    "discord",
    "spotify",
]

_PINNED_APPS = [
    i
    for i in Applications.get_all()
    if i and any(j in i.keywords.lower() for j in PINNED_APPS)
]


class DockApp(Widget.Button):
    def __init__(self, icon_name, keywords, **kwargs) -> None:
        self.indicators = Widget.Box([])
        self.keywords = keywords
        self.icon = Widget.Icon(icon_name, 40, hexpand=True, halign="center")

        super().__init__(
            children=Widget.Box(orientation="v", children=[self.icon, self.indicators]),
            halign="center",
            valign="center",
            classname="dock-app",
            **kwargs,
        )

        HyprlandService.connect(
            "activewindowv2", lambda _, *args: self.update_indicator(*args)
        )
        HyprlandService.connect(
            "openwindow", lambda _, *args: self.add_indicator(*args)
        )
        HyprlandService.connect(
            "closewindow", lambda _, *args: self.del_indicator(*args)
        )

    def update_indicator(self, address: str) -> None:
        for i in self.indicators.get_children():
            if getattr(i, "address") == address:
                i.set_classname("dock-app-indicator active")
            else:
                i.set_classname("dock-app-indicator inactive")

    def add_indicator(self, address: str, _, classname: str, __) -> None:
        if classname in self.keywords:
            self.indicators.add(
                Widget.Separator(
                    attributes=lambda self: setattr(self, "address", address),
                    classname="dock-app-indicator inactive",
                    hexpand=True,
                )
            )

    def del_indicator(self, address: str) -> None:
        for i in self.indicators.get_children():
            if getattr(i, "address") == address:
                return i.destroy()


def DockWidget(monitor=0):
    tmp = Widget.Box(
        classname="dock",
        spacing=10,
        children=[
            Widget.Button(
                Widget.Icon("view-app-grid-symbolic", 40),
                attributes=lambda self: setattr(self, "applauncher", None),
                classname="dock-app-launcher",
                onclick=lambda: Bash.run_async("potatocli --exec ToggleLauncher"),
            ),
            Widget.Separator("v", classname="separator"),
        ]
        + list(
            map(
                lambda app: DockApp(
                    icon_name=app.icon_name,
                    keywords=app.keywords,
                    primaryrelease=lambda: app.launch(),
                ),
                _PINNED_APPS,
            )
        ),
    )

    return Widget.Window(
        attributes=lambda self: ActiveWindow.bind(
            lambda v: self.close() if v else self.open()
        ),
        position="bottom",
        at={"bottom": 20},
        children=tmp,
        namespace=f"Dock_{monitor}",
    )


DockWindow = DockWidget()
DockWindow.open()
