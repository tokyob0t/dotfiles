from re import search as re_search
from typing import List, Union

from PotatoWidgets import Applications, Variable, Widget, wait
from PotatoWidgets.Services.Applications import App

from ..utils.apps import REPLACE_ICONS, CategorizedApps, StartMenuPinnedApps

StartMenuRevealer = Variable(False)
StartMenuEntryQuery = Variable(-1)
StartMenuEntry = Widget.Entry(
    hexpand=True,
    onchange=lambda t: StartMenuEntryQuery.set_value(str(t).lower()),
    onenter=lambda t: CloseStartMenu() if LaunchBestMatch(t) else None,
)


def CloseStartMenu() -> None:
    if StartMenuWindow.get_visible():
        wait(500, StartMenuWindow.close)
        StartMenuRevealer.value = False
        if StartMenuEntryQuery.value != -1:
            StartMenuEntryQuery.value = -1
            StartMenuEntry.set_text("")


def OpenStartMenu() -> None:
    if not StartMenuWindow.get_visible():
        if StartMenuEntryQuery.value != -1:
            StartMenuEntryQuery.value = -1
            StartMenuEntry.set_text("")

        StartMenuRevealer.value = True
        StartMenuWindow.open()


def GenerateAppCategory(app: App) -> Widget.Revealer:
    return Widget.Revealer(
        attributes=lambda self: (
            setattr(self, "keywords", app.keywords),
            setattr(self, "app", app),
            self.bind(
                StartMenuEntryQuery,
                lambda q: self.set_revealed(
                    q in [-1, -2] or re_search(q, getattr(self, "keywords"))
                ),
            ),
        ),
        transition="slideup",
        valign="start",
        hexpand=True,
        duration=250,
        children=Widget.Button(
            onclick=lambda: (app.launch(), CloseStartMenu()),
            hexpand=True,
            classname="app-category",
            children=Widget.Box(
                spacing=10,
                children=[
                    (
                        Widget.Image(
                            app.icon_name,
                            35,
                        )
                        if app.icon_name.endswith(
                            (".svg", ".png", ".jpg"),
                        )
                        and app.icon_name
                        else Widget.Icon(
                            REPLACE_ICONS.get(app.icon_name, app.icon_name)
                            or "application-x-addon-symbolic",
                            35,
                            classname="icon",
                        )
                    ),
                    Widget.Label(
                        app.name
                        or app.generic_name  # Use app.name if available, otherwise use app.generic_name
                        if re_search(
                            "[A-Z]", app.name or app.generic_name
                        )  # Check if any uppercase letter is present in app.name or app.generic_name
                        else (
                            app.name or app.generic_name
                        ).title()  # If no uppercase letters found, format the text as title case
                    ),
                ],
            ),
        ),
    )


def GenerateTitleCategory(i: dict) -> Widget.Revealer:
    return Widget.Revealer(
        attributes=lambda self: (
            setattr(self, "keywords", i["keywords"]),
            self.bind(
                StartMenuEntryQuery,
                lambda q: self.set_revealed(
                    q in [-1, -2] or re_search(q, self.keywords)
                ),
            ),
        ),
        transition="slideup",
        duration=250,
        valign="start",
        hexpand=True,
        children=Widget.Button(
            hexpand=True,
            classname="app-category-label",
            children=Widget.Label(
                i["category"].capitalize(),
                halign="start",
                valign="center",
            ),
        ),
    )


def GetBestMatch(query: str) -> Union[App, None]:
    # Doing this instead of using Applications().query()
    # bc the category has priority over the alphabetical order

    # Box Array
    if not query:
        return

    for box in CategorizedAppsList:
        # Revealer Array
        children: List[Widget.Revealer] = box.get_children()
        # First element is the label
        label: Widget.Label = children[0].get_children()[0].get_children()[0]

        if label.get_text().lower() == query[0]:
            # if app hasn't been found in the category
            match: Union[App, None] = next(
                (
                    getattr(i, "app")
                    for i in children[1:]
                    if query in getattr(i, "keywords")
                ),
                None,
            )

            if match:
                return match
            else:
                match = next((i for i in Applications().query(query)), None)
                return match


def LaunchBestMatch(query) -> bool:
    match = GetBestMatch(query)
    if match:
        match.launch()
        return True
    else:
        return False


CategorizedAppsList: List[Widget.Box] = [
    Widget.Box(
        orientation="v",
        hexpand=True,
        vexpand=True,
        valign="start",
        children=[]
        + [GenerateTitleCategory(i)]
        + [GenerateAppCategory(j) for j in i["apps"]],
    )
    for i in CategorizedApps()
]

StartMenuWindow = Widget.Window(
    position="bottom",
    namespace="StartMenuWindow",
    focusable="exclusive",
    children=Widget.Box(
        attributes=lambda self: self.bind(
            StartMenuRevealer,
            lambda o: self.set_classname(
                "startmenu-revealer {}".format("active" if o else "inactive")
            ),
        ),
        classname=f"startmenu-revealer inactive",
        children=Widget.Box(
            attributes=lambda self: self.bind(
                StartMenuEntryQuery,
                lambda o: self.set_classname(
                    f"startmenu-box {'active' if o not in [-1, -2] else ''}"
                ),
            ),
            classname="startmenu-box",
            orientation="v",
            hexpand=True,
            vexpand=True,
            children=[
                # Entry
                Widget.Box(
                    classname="top-section",
                    children=Widget.Box(
                        hexpand=True,
                        classname="startmenu-entry",
                        children=[
                            Widget.Label("󰍉", angle=-90, classname="nf-icon icon"),
                            StartMenuEntry,
                        ],
                    ),
                ),
                # Apps
                Widget.Box(
                    classname="mid-section",
                    hexpand=True,
                    vexpand=True,
                    children=[
                        # Left Side
                        Widget.Revealer(
                            attributes=lambda self: self.bind(
                                StartMenuEntryQuery,
                                lambda out: (
                                    self.set_classname(
                                        f"revealer left "
                                        + ("active" if out == -1 and out != -2 else "")
                                    ),
                                    self.set_revealed(
                                        True if (out == -1 and out != -2) else False
                                    ),
                                ),
                            ),
                            transition="slideright",
                            classname="revealer left active",
                            hexpand=True,
                            halign="end",
                            children=Widget.Box(
                                hexpand=True,
                                halign="center",
                                orientation="v",
                                children=[
                                    Widget.Box(
                                        classname="label-button-container",
                                        children=[
                                            Widget.Label("Pinned", halign="start"),
                                            Widget.Box(hexpand=True),
                                            Widget.Button(
                                                onclick=lambda: StartMenuEntryQuery.set_value(
                                                    -2
                                                ),
                                                halign="end",
                                                classname="apps-button",
                                                children=Widget.Box(
                                                    spacing=10,
                                                    children=[
                                                        Widget.Label("All Apps"),
                                                        Widget.Label(
                                                            "", classname="nf-icon"
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ],
                                    ),
                                ]
                                + StartMenuPinnedApps(),
                            ),
                        ),
                        # Right Side
                        Widget.Revealer(
                            attributes=lambda self: self.bind(
                                StartMenuEntryQuery,
                                lambda out: (
                                    self.set_classname(
                                        "revealer right "
                                        + ("active" if out != -1 else "")
                                    ),
                                    self.set_revealed(True if out != -1 else False),
                                ),
                            ),
                            transition="slideleft",
                            classname="revealer right",
                            reveal=False,
                            hexpand=True,
                            halign="start",
                            children=Widget.Box(
                                hexpand=True,
                                halign="center",
                                orientation="v",
                                spacing=20,
                                children=[
                                    Widget.Box(
                                        classname="label-button-container",
                                        children=[
                                            Widget.Button(
                                                onclick=lambda: StartMenuEntryQuery.set_value(
                                                    -1
                                                ),
                                                halign="end",
                                                classname="apps-button",
                                                children=Widget.Box(
                                                    spacing=10,
                                                    children=[
                                                        Widget.Label(
                                                            "", classname="nf-icon"
                                                        ),
                                                        Widget.Label("Pinned"),
                                                    ],
                                                ),
                                            ),
                                            Widget.Box(hexpand=True),
                                            Widget.Label("All apps", halign="start"),
                                        ],
                                    ),
                                    Widget.Box(
                                        hexpand=True,
                                        vexpand=True,
                                        # css="background: blue;",
                                        children=[
                                            Widget.Scroll(
                                                size=[300, 600],
                                                hexpand=True,
                                                vexpand=True,
                                                children=Widget.Box(
                                                    orientation="v",
                                                    valign="start",
                                                    children=CategorizedAppsList,
                                                ),
                                            ),
                                            Widget.Box(
                                                # css="background: cyan;",
                                                size=[350, 0],
                                                hexpand=True,
                                                vexpand=True,
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
                # Bottom
                Widget.Revealer(
                    attributes=lambda self: self.bind(
                        StartMenuEntryQuery,
                        lambda out: self.set_revealed(out == -1),
                    ),
                    classname="end-section",
                    transition="slidedown",
                    children=Widget.Box(),
                ),
            ],
        ),
    ),
)
