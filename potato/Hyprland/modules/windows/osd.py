from PotatoWidgets import Widget, wait

from ..utils.stats import (BRIGHTNESS_INFO, VOLUME_ICON, VOLUME_INFO,
                           OsdRevealer)

OsdWindow = Widget.Window(
    position="bottom",
    layer="overlay",
    namespace="OsdWindow",
    children=Widget.Box(
        size=[100, 150],
        orientation="v",
        valign="end",
        css="padding: 5px;",
        spacing=10,
        children=[
            Widget.Revealer(
                attributes=lambda self: self.bind(
                    OsdRevealer,
                    lambda out: self.set_revealed(out == 2),
                ),
                reveal=False,
                transition="slideup",
                halign="center",
                valign="end",
                classname="osd-revealer",
                children=Widget.Box(
                    classname="osd-box",
                    spacing=15,
                    children=[
                        VOLUME_ICON(),
                        Widget.ProgressBar(
                            classname="osd-scale",
                            valign="center",
                            value=VOLUME_INFO.value["value"],
                            attributes=lambda self: self.bind(
                                VOLUME_INFO, lambda out: self.set_value(out["value"])
                            ),
                        ),
                        Widget.Label(
                            attributes=lambda self: self.bind(
                                VOLUME_INFO, lambda out: self.set_text(out["value"])
                            ),
                            halign="center",
                            text=VOLUME_INFO.value["value"],
                        ),
                    ],
                ),
            ),
            Widget.Revealer(
                attributes=lambda self: self.bind(
                    OsdRevealer,
                    lambda out: self.set_revealed(out == 1),
                ),
                reveal=False,
                transition="slideup",
                halign="center",
                valign="end",
                classname="osd-revealer bottom inactive",
                children=Widget.Box(
                    classname="osd-box",
                    spacing=15,
                    children=[
                        Widget.Icon(
                            "display-brightness-symbolic",
                            24,
                            css="margin: -5px; color: #111111;",
                            classname="icon",
                        ),
                        Widget.ProgressBar(
                            classname="osd-scale",
                            value=BRIGHTNESS_INFO.value["value"],
                            valign="center",
                            attributes=lambda self: self.bind(
                                BRIGHTNESS_INFO,
                                lambda out: self.set_value(out["value"]),
                            ),
                        ),
                        Widget.Label(
                            attributes=lambda self: self.bind(
                                BRIGHTNESS_INFO, lambda out: self.set_text(out["value"])
                            ),
                            halign="center",
                            text=BRIGHTNESS_INFO.value["value"],
                        ),
                    ],
                ),
            ),
        ],
    ),
)
# OsdWindow.open()
