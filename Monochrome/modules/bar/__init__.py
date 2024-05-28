from datetime import datetime

from PotatoWidgets import Widget, interval

from ..common import *
from ..common import BATTERY_ICON, NETWORK_ICON, VOLUME_ICON, WorkspacesWidget


def bar_clock() -> Widget.Label:
    label = Widget.Label("00\n00\n00", classname="clock")
    interval("1s", lambda: label.set_text(datetime.now().strftime("%H\n%M\n%S")))
    return label


def Bar(monitor: int = 0):
    return Widget.Window(
        size=[50, "90%"],
        namespace=f"Bar_{monitor}",
        position="left",
        exclusive=True,
        monitor=monitor,
        children=Widget.CenterBox(
            classname="bar",
            orientation="v",
            start=Widget.Box(
                halign="center",
                orientation="v",
                children=Widget.Box(
                    classname="pfp", css="min-width: 2em; min-height: 2em;"
                ),
            ),
            center=Widget.Box(
                orientation="v",
                children=[
                    Widget.Box(
                        classname="center-top-container",
                        halign="end",
                        children=Widget.Label("AAA", angle=90),
                    ),
                    Widget.Box(
                        spacing=10,
                        orientation="v",
                        vexpand=True,
                        classname="center-container",
                        size=[0, 400],
                        children=[
                            WorkspacesWidget(),
                        ],
                    ),
                    Widget.Box(classname="center-bottom-container", halign="end"),
                ],
            ),
            end=Widget.Box(
                orientation="v",
                halign="center",
                spacing=20,
                children=[
                    Widget.Box(
                        spacing=10,
                        orientation="v",
                        classname="module",
                        children=[NETWORK_ICON(), VOLUME_ICON(), BATTERY_ICON()],
                    ),
                    bar_clock(),
                ],
            ),
        ),
    )


TopBarWindow = Bar(0)
TopBarWindow.open()
