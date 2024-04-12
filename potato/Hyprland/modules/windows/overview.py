import subprocess

from PotatoWidgets import Variable, Widget, get_screen_size, lookup_icon, wait

from ..utils.apps import REPLACE_ICONS
from ..utils.hypr import current_workspace, window_classnames

SCALE = 6.5

WIDTH, HEIGHT = get_screen_size()

OverViewRevealer = Variable(False)


def CloseOverview():
    OverViewRevealer.set_value(False)
    wait(250, OverView.close)


def OpenOverview():
    OverView.open()
    window_classnames.set_value(window_classnames.get_value())
    OverViewRevealer.set_value(True)


class Window(Widget.Button):
    def __init__(self, data, **kwargs):
        super().__init__(
            classname="windowbutton",
            onmiddleclick=lambda: subprocess.Popen(
                [
                    "hyprctl",
                    "dispatch",
                    "closewindow",
                    f'address:{data["address"]}',
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            ),
            primaryrelease=lambda: (
                CloseOverview(),
                subprocess.Popen(
                    [
                        "hyprctl",
                        "dispatch",
                        "focuswindow",
                        f'address:{data["address"]}',
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                ),
            ),
            secondaryrelease=lambda event: Widget.Menu(
                classname="overviewmenu menu",
                children=[
                    Widget.MenuItem(
                        Widget.Label("Close Window", xalign=0),
                        classname="windowmenuitem",
                        onactivate=lambda: subprocess.Popen(
                            [
                                "hyprctl",
                                "dispatch",
                                "closewindow",
                                f'address:{data["address"]}',
                            ],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL,
                        ),
                    ),
                    Widget.MenuItem(
                        Widget.Label("Send to Workspace", xalign=0),
                        classname="windowmenuitem",
                        submenu=Widget.Menu(
                            classname="menu",
                            children=[
                                (
                                    lambda i: Widget.MenuItem(
                                        Widget.Label(
                                            f"Workspace {i}",
                                            xalign=0,
                                        ),
                                        classname="windowmenuitem",
                                        onactivate=lambda: subprocess.Popen(
                                            [
                                                "hyprctl",
                                                "dispatch",
                                                "movetoworkspacesilent",
                                                f'{i},address:{data["address"]}',
                                            ],
                                            stdout=subprocess.DEVNULL,
                                            stderr=subprocess.DEVNULL,
                                        ),
                                    )
                                )(i)
                                for i in range(1, 8)
                            ],
                        ),
                    ),
                ],
            ).popup_at_pointer(event),
            **kwargs,
        )

        self.data: dict = data
        self.icon: Widget.Image = Widget.Image(
            lookup_icon(
                REPLACE_ICONS.get(self.data["initialClass"], self.data["initialName"]),
                fallback=REPLACE_ICONS.get(self.data["name"]) or self.data["name"],
            ),
            [
                (self.data["size"][0] / (2 * SCALE)) * 0.85,
                (self.data["size"][1] / (2 * SCALE)) * 0.85,
            ],
            halign="center",
            valign="center",
        )
        self.add(
            Widget.Box(
                vexpand=True,
                hexpand=True,
                children=Widget.Box(
                    hexpand=True,
                    vexpand=True,
                    halign="center",
                    valign="center",
                    children=self.icon,
                ),
            )
        )
        self.update_data(data)

    def update_data(self, new_data: dict) -> None:
        self.data: dict = new_data

        self.set_css(
            f"""
            min-width: {self.data["size"][0] // SCALE }px;
            min-height: {self.data["size"][1] // SCALE }px;
            """
        )

        self.icon.set_image(
            lookup_icon(
                REPLACE_ICONS.get(self.data["name"].lower()) or self.data["name"],
                fallback=REPLACE_ICONS.get(self.data["title"].lower())
                or self.data["title"],
            ),
        )
        self.icon.set_size(
            [
                self.data["size"][0] / 2 / SCALE * 85 / 100,
                self.data["size"][1] / 2 / SCALE * 85 / 100,
            ]
        )


class Workspace(Widget.Fixed):
    def __init__(self, data, **kwargs) -> None:
        super().__init__(**kwargs)

        self.data = data

        self.bind(window_classnames, self.update)

        self.bind(
            OverViewRevealer,
            lambda out: self.update(window_classnames.get_value()) if out else None,
        )

    def clear(self, data):
        address_list = [i["address"] for i in data]
        for i in self.get_children():
            if i.data["address"] not in address_list:
                self.remove(i)
                i.destroy()

    def update(self, new_data):
        new_data = next(i for i in new_data if i["id"] == self.data["id"])
        self.get_parent().get_parent().get_parent().get_parent().set_visible(
            bool(new_data["windows"])
        )

        if (
            new_data["windows"] != self.data["windows"]
            and OverView.get_visible() == True
        ):
            self.clear(new_data["windows"])

            for win_data in new_data["windows"]:
                win_data["at"][1] = win_data["at"][1] + 25

                window_spotted = next(
                    (
                        i
                        for i in self.get_children()
                        if i.data["address"] == win_data["address"]
                    ),
                    False,
                )

                if window_spotted:
                    if win_data != window_spotted.data:
                        window_spotted.update_data(win_data)
                        self.move(
                            window_spotted,
                            window_spotted.data["at"][0] // SCALE,
                            window_spotted.data["at"][1] // SCALE,
                        )
                else:
                    new_window = Window(win_data)
                    self.put(
                        new_window,
                        new_window.data["at"][0] // SCALE,
                        new_window.data["at"][1] // SCALE,
                    )

            self.data["windows"] = new_data["windows"]
            self.show_all()


OverViewWidget = Widget.Box(
    attributes=lambda self: self.bind(
        OverViewRevealer,
        lambda out: self.set_classname(
            "overviewrevealer " + ("active" if out else "inactive")
        ),
    ),
    valign="end",
    classname="overviewrevealer inactive",
    children=Widget.Scroll(
        size=[
            WIDTH - 50,
            int(HEIGHT // SCALE + 50),
        ],
        vexpand=True,
        hexpand=True,
        halign="center",
        valign="end",
        classname="overviewscroll",
        children=Widget.Box(
            halign="center",
            valign="center",
            spacing=5,
            classname="workspacesbox",
            children=[
                (
                    lambda wp: Widget.Box(
                        children=Widget.Overlay(
                            vexpand=True,
                            hexpand=True,
                            children=[
                                Widget.Button(
                                    primaryrelease=lambda: subprocess.Popen(
                                        [
                                            "hyprctl",
                                            "dispatch",
                                            "workspace",
                                            f"{wp['id']}",
                                        ],
                                        stdout=subprocess.DEVNULL,
                                        stderr=subprocess.DEVNULL,
                                    ),
                                    children=Widget.Box(
                                        attributes=lambda self: (
                                            setattr(self, "id", wp["id"]),
                                            self.bind(
                                                current_workspace,
                                                lambda out: self.set_classname(
                                                    "workspace active"
                                                    if out == self.id
                                                    else "workspace"
                                                ),
                                            ),
                                        ),
                                        classname="workspace inactive",
                                        orientation="v",
                                        spacing=5,
                                        children=[
                                            Widget.Label(
                                                f"Desktop {wp['id']}",
                                                halign="start",
                                                css="margin-left: 10px; font-weight: 600;",
                                            ),
                                            Widget.Box(
                                                classname="windowcontainer",
                                                size=[
                                                    round(WIDTH / SCALE),
                                                    round(HEIGHT // SCALE),
                                                ],
                                                children=Workspace(
                                                    data=wp,
                                                    hexpand=True,
                                                    vexpand=True,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Widget.Separator(
                                    halign="center",
                                    valign="end",
                                    attributes=lambda self: (
                                        setattr(self, "id", wp["id"]),
                                        self.bind(
                                            current_workspace,
                                            lambda out: self.set_classname(
                                                "activeline"
                                                if out == self.id
                                                else "inactiveline"
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        )
                    )
                )(wp)
                for wp in window_classnames.get_value()
            ],
        ),
    ),
)


def GenerateCurrentWorkspaceWindows(data, alignment):
    app_name = data["name"].lower()
    app_title = data["title"].lower()

    app_title_icon = lookup_icon(
        REPLACE_ICONS.get(app_title.lower()) or app_title,
        fallback="application-x-addon-symbolic",
    )

    app_icon = lookup_icon(
        REPLACE_ICONS.get(app_name.lower()) or app_name,
        fallback=REPLACE_ICONS.get(app_title.lower()) or app_title,
    )

    app_address = data["address"]
    app_size = data["size"]

    return Widget.Box(
        classname="bigwindow",
        halign="center",
        valign=alignment,
        children=Widget.Box(
            size=[max(app_size[0] // SCALE, 50), max(app_size[1] // SCALE, 125)],
            orientation="v",
            children=[
                Widget.Box(
                    classname="titlebar",
                    valign="center",
                    children=[
                        Widget.Box(
                            hexpand=True,
                            spacing=10,
                            children=[
                                Widget.Image(app_title_icon, 20),
                                Widget.Label(
                                    app_name.title(),
                                    maxchars=app_size[0] // (SCALE**2),
                                ),
                            ],
                        ),
                        Widget.Button(
                            onclick=lambda: subprocess.Popen(
                                [
                                    "hyprctl",
                                    "dispatch",
                                    "closewindow",
                                    f"address:{app_address}",
                                ],
                                stdout=subprocess.DEVNULL,
                                stderr=subprocess.DEVNULL,
                            ),
                            children=Widget.Icon(
                                "window-close-symbolic", 20, classname="icon black"
                            ),
                        ),
                    ],
                ),
                Widget.Button(
                    vexpand=True,
                    hexpand=True,
                    primaryrelease=lambda: (
                        CloseOverview(),
                        subprocess.Popen(
                            [
                                "hyprctl",
                                "dispatch",
                                "focuswindow",
                                f"address:{app_address}",
                            ],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL,
                        ),
                    ),
                    secondaryrelease=lambda event: Widget.Menu(
                        classname="overviewmenu menu",
                        children=[
                            Widget.MenuItem(
                                Widget.Label("Close Window", xalign=0),
                                classname="windowmenuitem",
                                onactivate=lambda: subprocess.Popen(
                                    [
                                        "hyprctl",
                                        "dispatch",
                                        "closewindow",
                                        f"address:{app_address}",
                                    ],
                                    stdout=subprocess.DEVNULL,
                                    stderr=subprocess.DEVNULL,
                                ),
                            ),
                            Widget.MenuItem(
                                Widget.Label("Send to Workspace", xalign=0),
                                classname="windowmenuitem",
                                submenu=Widget.Menu(
                                    classname="menu",
                                    children=[
                                        (
                                            lambda i: Widget.MenuItem(
                                                Widget.Label(
                                                    f"Workspace {i}",
                                                    xalign=0,
                                                ),
                                                classname="windowmenuitem",
                                                onactivate=lambda: subprocess.Popen(
                                                    [
                                                        "hyprctl",
                                                        "dispatch",
                                                        "movetoworkspacesilent",
                                                        f"{i},address:{app_address}",
                                                    ],
                                                    stdout=subprocess.DEVNULL,
                                                    stderr=subprocess.DEVNULL,
                                                ),
                                            )
                                        )(i)
                                        for i in range(1, 8)
                                    ],
                                ),
                            ),
                        ],
                    ).popup_at_pointer(event),
                    children=Widget.Box(
                        hexpand=True,
                        vexpand=True,
                        halign="center",
                        valign="center",
                        children=Widget.Image(
                            app_icon,
                            size=[
                                max(
                                    [
                                        app_size[0] // (SCALE + 10),
                                        35,
                                    ]
                                ),
                                max(
                                    [
                                        app_size[1] // (SCALE + 10),
                                        35,
                                    ]
                                ),
                            ],
                        ),
                    ),
                ),
            ],
        ),
    )


def GetCurrentWorkspaceWindows():
    windows = next(
        (
            i
            for i in window_classnames.get_value()
            if i["id"] == current_workspace.get_value()
        ),
        {},
    ).get("windows")

    if windows:
        index_30 = int(len(windows) * 0.3)
        index_70 = int(len(windows) * 0.7)

        if len(windows) % 2 != 0:
            index_30 += 1
            index_70 += 1

        row1 = (windows[:index_30], "end")
        row3 = (windows[index_70:], "start")
        row2 = (
            windows[index_30:index_70],
            "center" if row1[0] and row3[0] else "start" if row1[0] else "end",
        )

        return [
            (
                lambda row: Widget.Box(
                    spacing=20,
                    halign="center",
                    children=[
                        GenerateCurrentWorkspaceWindows(i, row[1]) for i in row[0]
                    ],
                    visible=bool(row[1]),
                )
            )(row)
            for row in [row1, row2, row3]
        ]
    else:
        return []


def clear_childrens(self, data):
    if not data:
        for i in self.get_children():
            i.destroy()
            self.remove(i)
    else:
        self.set_children(data)


OverView = Widget.Window(
    position="bottom top left right",
    size=["100%", 1080 - 50],
    namespace="OverView",
    children=Widget.Box(
        classname="OverView",
        orientation="v",
        hexpand=True,
        vexpand=True,
        children=Widget.Overlay(
            hexpand=True,
            vexpand=True,
            children=[
                Widget.Box(
                    vexpand=True,
                    hexpand=True,
                    halign="center",
                    valign="center",
                    orientation="v",
                    css="margin-bottom: 200px;",
                    spacing=20,
                    attributes=lambda self: (
                        self.bind(
                            OverViewRevealer,
                            lambda _: (
                                clear_childrens(self, GetCurrentWorkspaceWindows())
                                if OverViewRevealer.get_value()
                                else None
                            ),
                        ),
                        self.bind(
                            current_workspace,
                            lambda _: (
                                clear_childrens(self, GetCurrentWorkspaceWindows())
                                if OverViewRevealer.get_value()
                                else None
                            ),
                        ),
                        self.bind(
                            window_classnames,
                            lambda _: (
                                clear_childrens(self, GetCurrentWorkspaceWindows())
                                if OverViewRevealer.get_value()
                                else None
                            ),
                        ),
                    ),
                ),
                OverViewWidget,
            ],
        ),
    ),
)
