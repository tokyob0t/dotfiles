from datetime import datetime

from PotatoWidgets import Poll, Variable, Widget, wait
from PotatoWidgets.Imports import *

from .newspanelstuff import TermWidget, ThisPCInfo, WeatherWidget

NewsPanelRevealer = Variable(False)


def CloseNewsPanel():
    if NewsPanel.get_visible():
        wait(500, NewsPanel.close)
        NewsPanelRevealer.value = False


def OpenNewsPanel():
    if not NewsPanel.get_visible():
        NewsPanel.open()
        NewsPanelRevealer.value = True


class NewsPanelWidget(Widget.Box):
    def __init__(
        self,
        icon: str,
        title: str,
        children: Union[List[Union[Gtk.Widget, None]], Gtk.Widget, Any] = ...,
        size: Union[int, str, List[Union[int, str]], List[int]] = 0,
        attributes: Callable = lambda self: self,
        css: str = "",
        hexpand: bool = False,
        vexpand: bool = False,
        classname="",
        dark_mode=False,
    ) -> None:
        titlebar = Widget.Box(
            spacing=10,
            hexpand=True,
            classname="newspanel-widget-titlebar",
            children=[
                Widget.Icon(icon),
                Widget.Label(
                    title,
                    classname="newspanel-widget-title "
                    + ("black" if not dark_mode else "white"),
                ),
                Widget.Button(
                    hexpand=True,
                    halign="end",
                    valign="center",
                    classname="newspanel-widget-button",
                    children=Widget.Label(
                        "",
                        classname="nf-icon " + ("black" if not dark_mode else "white"),
                        valign="center",
                        halign="center",
                    ),
                ),
            ],
        )
        super().__init__(
            children=Widget.Box(
                orientation="v",
                hexpand=True,
                spacing=10,
                children=[
                    titlebar,
                    children,
                ],
            ),
            orientation="v",
            spacing=0,
            homogeneous=False,
            size=size,
            attributes=attributes,
            css=css,
            halign="center",
            valign="start",
            hexpand=hexpand,
            vexpand=vexpand,
            visible=True,
            classname="newspanel-widget " + classname,
        )


SystemWidget = NewsPanelWidget(
    icon="configuration_section",
    title="System",
    classname="system-widget",
    dark_mode=True,
    children=Widget.Box(
        orientation="v",
        halign="center",
        hexpand=True,
        children=[
            Widget.Icon("computer-laptop", 100, classname="icon", halign="center"),
            # Widget.Icon("archlinux", 120, classname="icon", halign="center"),
            Widget.Box(
                orientation="v",
                children=[
                    Widget.Label(
                        " ".join(ThisPCInfo.value["pc"].split()[:4]),
                        classname="white system-widget-title",
                        halign="center",
                    ),
                    Widget.Label(
                        ThisPCInfo.value["architecture"],
                        classname="architecture",
                    ),
                ],
            ),
            Widget.Box(
                vexpand=True,
                valign="start",
                orientation="v",
                children=[
                    (
                        lambda key="", value="": Widget.Box(
                            spacing=10,
                            halign="center",
                            homogeneous=True,
                            children=[
                                Widget.Label(
                                    (key.upper() if len(key) <= 3 else key.title()),
                                    classname="white component left",
                                    xalign=1,
                                ),
                                Widget.Label(
                                    value.replace(
                                        "Intel(R) Core(TM) ",
                                        "",
                                    )
                                    .replace(
                                        "CPU @ 2.50GHz",
                                        "",
                                    )
                                    .replace(
                                        "NVIDIA GeForce ",
                                        "",
                                    ),
                                    classname="white component right",
                                    xalign=0,
                                ),
                            ],
                        )
                    )(str(i), str(j))
                    for i, j in ThisPCInfo.value.items()
                    if i not in ["pc", "architecture"]
                ],
            ),
        ],
    ),
)


NewsPanel = Widget.Window(
    position="left",
    # size=[10, 1080 - 50],
    size=[10, 10],
    focusable=True,
    namespace="NewsPanel",
    children=Widget.Box(
        attributes=lambda self: self.bind(
            NewsPanelRevealer,
            lambda o: self.set_classname(
                "newspanel-revealer {}".format("active" if o else "inactive")
            ),
        ),
        hexpand=True,
        vexpand=True,
        halign="start",
        classname="newspanel-revealer inactive",
        children=Widget.Box(
            orientation="v",
            hexpand=True,
            vexpand=True,
            classname="newspanel-box",
            size=[800, 1015],
            spacing=10,
            children=[
                Widget.Label(
                    Poll("1m", lambda: datetime.now().strftime("%H:%M %p")),
                    hexpand=True,
                    halign="center",
                    classname="time",
                ),
                Widget.Scroll(
                    hexpand=True,
                    vexpand=True,
                    children=Widget.Box(
                        spacing=10,
                        hexpand=True,
                        vexpand=True,
                        halign="center",
                        homogeneous=True,
                        children=[
                            Widget.Box(
                                orientation="v",
                                spacing=10,
                                hexpand=True,
                                children=[SystemWidget],
                            ),
                            Widget.Box(
                                orientation="v",
                                spacing=10,
                                hexpand=True,
                                children=[
                                    # NewsPanelWidget(
                                    #    icon="weather-widget",
                                    #    title="Weather",
                                    #    classname="weather-widget",
                                    #    # children=WeatherWidget,
                                    #    children=Widget.Box(),
                                    # ),
                                    NewsPanelWidget(
                                        icon="colorimeter-colorhug",
                                        title="Random Waifu",
                                        classname="waifu-widget",
                                        children=Widget.Box(
                                            halign="center",
                                            valign="center",
                                            hexpand=True,
                                            vexpand=True,
                                            size=[0, 300],
                                            children=Widget.Label(
                                                "WIP",
                                            ),
                                        ),
                                    ),
                                    NewsPanelWidget(
                                        icon="terminal",
                                        title="Terminal",
                                        classname="terminal-widget",
                                        children=TermWidget,
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),
            ],
        ),
    ),
)
