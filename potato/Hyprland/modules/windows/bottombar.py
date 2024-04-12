import subprocess
from datetime import datetime

from PotatoWidgets import (DIR_CONFIG_POTATO, DIR_HOME, Bash, BatteryService,
                           NotificationsService, Poll, Widget, lookup_icon)

from ..utils.apps import BottombarApps
from ..utils.hypr import CONF_FILE
from ..utils.network_manager import network_info
from ..utils.stats import BATTERY_ICON, VOLUME_ICON


def exec_func(func):
    subprocess.Popen(["/usr/bin/potatocli", "--exec", func])


BottomBar = Widget.Window(
    size=["100%", 50],
    position="bottom",
    layer="top",
    exclusive=True,
    namespace="BottomBar",
    children=Widget.CenterBox(
        classname="bottombar",
        start=Widget.Box(
            children=Widget.Button(
                classname="module larger",
                onclick=lambda: exec_func("ToggleNewsPanel"),
                children=Widget.Image(
                    f"{DIR_CONFIG_POTATO}/Hyprland/scss/images/icons/win-news.png",
                    35,
                ),
            )
        ),
        center=Widget.Box(
            hexpand=True,
            halign="center",
            valign="center",
            spacing=10,
            children=[]
            + [
                Widget.Button(
                    classname="module winbutton",
                    onclick=lambda: exec_func("ToggleStartMenu"),
                    children=Widget.Icon(
                        "distributor-logo-windows",
                        40,
                    ),
                ),
                Widget.Button(
                    classname="module",
                    onclick=lambda: exec_func("ToggleOverview"),
                    children=Widget.Icon(
                        "cs-workspaces",
                        35,
                    ),
                ),
            ]
            + BottombarApps(),
        ),
        end=Widget.Box(
            valign="center",
            spacing=10,
            children=[
                Widget.Button(
                    classname="module",
                    children=Widget.Label(
                        text=CONF_FILE.value["kb_layout"]["str"][:3].upper(),
                        css="font-size: 15px;",
                    ),
                ),
                Widget.Button(
                    classname="module large",
                    onclick=lambda: exec_func("ToggleControlPanel"),
                    children=Widget.Box(
                        spacing=10,
                        children=[
                            Widget.Icon(
                                "network-wireless-signal-none-symbolic",
                                16,
                                classname="icon",
                                attributes=lambda self: self.bind(
                                    network_info,
                                    lambda out: self.set_icon(out["wifi"]["icon"]),
                                ),
                            ),
                            Widget.Button(
                                children=VOLUME_ICON(),
                                secondaryrelease=lambda: Bash.run(
                                    "pactl set-sink-mute @DEFAULT_SINK@ toggle",
                                ),
                            ),
                            BATTERY_ICON(),
                        ],
                    ),
                ),
                Widget.Button(
                    classname="module large",
                    children=Widget.Box(
                        orientation="v",
                        valign="center",
                        children=[
                            Widget.Label(
                                Poll(
                                    "1m",
                                    lambda: datetime.now().strftime("%H:%M %p"),
                                ),
                                classname="time hour",
                                xalign=1,
                            ),
                            Widget.Label(
                                Poll(
                                    "1m",
                                    lambda: datetime.now().strftime("%d/%m/%Y"),
                                ),
                                classname="time date",
                                xalign=1,
                            ),
                        ],
                    ),
                ),
                Widget.Revealer(
                    transition="slideleft",
                    reveal=False,
                    duration=250,
                    attributes=lambda self: NotificationsService().connect(
                        "count",
                        lambda _, count: self.set_revealed(bool(count)),
                    ),
                    children=Widget.Button(
                        onmiddleclick=lambda: NotificationsService().clear(),
                        classname="notifIndicator",
                        valign="center",
                        children=Widget.Label(
                            text=NotificationsService().bind("count"),
                            hexpand=True,
                        ),
                    ),
                ),
            ],
        ),
    ),
)
