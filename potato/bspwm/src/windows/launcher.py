from PotatoWidgets import Applications, Variable, Widget, lookup_icon

Applications().add_blacklist("Vscodium - Wayland")
Applications().add_whitelist("Icon Browser")


def ToggleLauncher() -> None:
    if AppLauncher.get_visible():
        AppLauncher.close()
    else:
        AppLauncher.open()


def GenerateApp(entry):
    _actioned = lambda: (
        entry.launch(),
        AppLauncher.close(),
        AppQuery.set_value(""),
        AppEntry.set_text(""),
    )
    if entry.icon_name:
        if str(entry.icon_name).endswith((".png", ".svg", ".jpg")):
            _ICON = Widget.Image(entry.icon_name, 35)
        else:
            _ICON = Widget.Icon(entry.icon_name, 35)
    else:
        _ICON = Widget.Icon("application-x-addon-symbolic", 35)

    _app = Widget.Revealer(
        valign="start",
        transition="slideup",
        duration=250,
        reveal=True,
        attributes=lambda self: (
            setattr(self, "keywords", entry.keywords),
            setattr(self, "launch", _actioned),
            self.bind(
                AppQuery,
                lambda query: self.set_revealed(str(query).lower() in self.keywords),
            ),
        ),
        children=Widget.Button(
            classname="app",
            valign="start",
            onclick=_actioned,
            children=Widget.Box(
                spacing=10,
                children=[
                    _ICON,
                    Widget.Box(
                        orientation="v",
                        vexpand=True,
                        children=[
                            Widget.Label(
                                entry.name.title(),
                                wrap=True,
                                halign="start",
                                classname="name",
                                xalign=0,
                                justify="left",
                            ),
                            Widget.Label(
                                entry.comment or entry.generic_name,
                                wrap=True,
                                visible=bool(entry.comment or entry.generic_name),
                                classname="comment",
                                halign="start",
                                justify="left",
                                xalign=0,
                            ),
                        ],
                    ),
                ],
            ),
        ),
    )
    return _app


AppQuery = Variable("")

SortedApps = Applications().get_all()
SortedApps.sort(key=lambda app: app.name)

AppsList = Widget.Scroll(
    hexpand=True,
    vexpand=True,
    children=Widget.Box(
        orientation="v",
        children=[GenerateApp(app) for app in SortedApps],
    ),
)

AppEntry = Widget.Entry(
    onchange=AppQuery.set_value,
    onenter=lambda text: next(
        app.launch()
        for app in AppsList.get_children()[0].get_children()[0].get_children()
        if str(text).lower() in app.keywords
    ),
)


AppLauncher = Widget.Window(
    size=[500, 600],
    layer="dialog",
    namespace="AppLauncher",
    children=Widget.Box(
        classname="launcher",
        orientation="v",
        spacing=20,
        children=[
            AppEntry,
            AppsList,
        ],
    ),
)
