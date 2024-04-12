import subprocess

from PotatoWidgets import (BatteryService, Listener, Poll, Variable, Widget,
                           wait)

from ..utils.media_widget import MediaWidget
from ..utils.stats import (BATTERY_ICON, BRIGHTNESS_ICON, BRIGHTNESS_INFO,
                           VOLUME_ICON, VOLUME_INFO)

ControlPanelRevealer = Variable(False)


def CloseControlPanel():
    if ControlPanel.get_visible():
        wait(500, ControlPanel.close)
        ControlPanelRevealer.value = False


def OpenControlPanel():
    if not ControlPanel.get_visible():
        ControlPanel.open()
        ControlPanelRevealer.value = True


ControlPanelMainBox = Widget.Box(
    hexpand=True,
    vexpand=True,
    classname="quicksettings-box",
    orientation="v",
    children=[
        Widget.Box(
            classname="topsection",
            vexpand=True,
            orientation="v",
            children=[
                # Buttons
                Widget.Box(vexpand=True),
                # Sliders
                Widget.Box(
                    orientation="v",
                    hexpand=True,
                    valign="end",
                    spacing=20,
                    children=[
                        Widget.Box(
                            spacing=10,
                            children=[
                                BRIGHTNESS_ICON(24, css="margin: -5px -3px -5px -5px;"),
                                Widget.Scale(
                                    min=10,
                                    max=100,
                                    value=BRIGHTNESS_INFO.value["value"],
                                    classname="volumescale",
                                    hexpand=True,
                                    onchange=lambda value: subprocess.run(
                                        [
                                            "brightnessctl",
                                            "set",
                                            f"{value}%",
                                        ],
                                        stdout=subprocess.DEVNULL,
                                        stderr=subprocess.DEVNULL,
                                    ),
                                    attributes=lambda self: self.bind(
                                        BRIGHTNESS_INFO,
                                        lambda out: self.set_value(out["value"]),
                                    ),
                                ),
                            ],
                        ),
                        Widget.Box(
                            spacing=10,
                            children=[
                                Widget.Button(
                                    children=VOLUME_ICON(),
                                    onclick=lambda: subprocess.run(
                                        [
                                            "pactl",
                                            "set-sink-mute",
                                            "@DEFAULT_SINK@",
                                            "toggle",
                                        ]
                                    ),
                                ),
                                Widget.Scale(
                                    min=0,
                                    max=100,
                                    value=VOLUME_INFO.value["value"],
                                    classname="volumescale",
                                    hexpand=True,
                                    onchange=lambda value: subprocess.run(
                                        [
                                            "pactl",
                                            "set-sink-volume",
                                            "@DEFAULT_SINK@",
                                            f"{value}%",
                                        ],
                                        stdout=subprocess.DEVNULL,
                                        stderr=subprocess.DEVNULL,
                                    ),
                                    attributes=lambda self: self.bind(
                                        VOLUME_INFO,
                                        lambda out: self.set_value(out["value"]),
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ],
        ),
        Widget.Box(
            classname="bottomsection",
            hexpand=True,
            spacing=20,
            children=[
                Widget.Box(
                    hexpand=True,
                    spacing=5,
                    children=[
                        BATTERY_ICON(),
                        Widget.Label(
                            text="100%",
                            valign="center",
                            classname="batterylabel",
                            attributes=lambda self: self.bind(
                                BatteryService().bind("percentage"),
                                lambda o: self.set_text("{}%".format(round(o))),
                            ),
                        ),
                    ],
                ),
            ]
            + [
                Widget.Label(
                    i[0],
                    classname="nf-icon",
                    css=f"font-size: {i[1]}px;",
                    # css=f"font-size: {i[1]}px; margin-top: -{i[1] // 5}px; margin-bottom: {i[1]//5}px",
                    valign="center",
                    vexpand=True,
                )
                for i in [
                    # ["", 18],
                    ["", 17],
                ]
            ],
        ),
    ],
)


ControlPanel = Widget.Window(
    position="bottom right",
    children=Widget.Box(
        hexpand=True,
        vexpand=True,
        valign="end",
        css="min-width: 500px; min-height: 500px;",
        classname="quicksettings-revealer inactive",
        attributes=lambda self: self.bind(
            ControlPanelRevealer,
            lambda out: self.set_classname(
                "quicksettings-revealer " + ("active" if out else "inactive")
            ),
        ),
        children=Widget.Box(
            orientation="v",
            hexpand=True,
            vexpand=True,
            spacing=10,
            children=[MediaWidget, ControlPanelMainBox],
        ),
    ),
)
