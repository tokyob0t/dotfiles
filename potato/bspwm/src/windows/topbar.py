from datetime import datetime

from PotatoWidgets import Bash, BatteryService,  Poll, Widget

from ..scripts import *

Topbar = Widget.Window(
    size=[50, "90%"],
    at={"left": 10},
    position="left",
    exclusive=True,
    namespace="Topbar",
    children=Widget.CenterBox(
        orientation="v",
        classname="topbar",
        start=Widget.Box(
            children=Widget.Label(
                halign="center",
                hexpand=True,
                angle=90,
                attributes=lambda self: self.bind(
                    CurrentWindowsInfo,
                    lambda out: self.set_text(out["client"]["className"].title()),
                ),
            )
        ),
        center=Widget.Box(
            attributes=lambda self: self.bind(
                WorkspaceInfo,
                lambda out: self.set_children(
                    [
                (
                    lambda i: Widget.Button(
                        onclick=lambda: Bash.run(
                            f"bspc desktop -f {i['id']}"
                        ),
                        classname="workspace "
                        + ("active" if bool(i["windows"]) else "inactive"),
                    )
                )(i)
                        for i in out
                    ][::-1]
                ),
            ),
            children=[
                (
                    lambda i: Widget.Button(
                        onclick=lambda: Bash.run(
                            f"bspc desktop -f {i['id']}"
                        ),
                        classname="workspace "
                        + ("active" if bool(i["windows"]) else "inactive"),
                    )
                )(i)
                for i in WorkspaceInfo.value
            ][::-1],
            hexpand=True,
            halign="center",
            orientation="v",
            spacing=10,
        ),
        end=Widget.Box(
            orientation="v",
            spacing=15,
            children=[
                Widget.Overlay(
                    [
                        Widget.ProgressBar(
                            value=BatteryService().bind("percentage"),
                            orientation="v",
                            halign="center",
                            classname="battery-progress",
                            inverted=True,
                        ),
                        Widget.Label(text="󱐋", css="color: #111;", classname="nf-icon"),
                    ],
                ),
                Widget.Box(
                    orientation="v",
                    children=[
                        Widget.Label(Poll("1m", lambda: datetime.now().strftime("%H"))),
                        Widget.Label(Poll("1m", lambda: datetime.now().strftime("%M"))),
                    ],
                ),
            ],
        ),
    ),
)

Topbar.bind(
    CurrentWindowsInfo,
    lambda out: Topbar.set_visible(
        out["client"]["tiledRectangle"]["width"] != 1920
        and out["client"]["tiledRectangle"]["height"] != 1080
    ),
)
