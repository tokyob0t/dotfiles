from fuzzywuzzy import fuzz
from PotatoWidgets import Widget, wait
from PotatoWidgets.Services import App, Applications

from ..dock import ActiveWindow, DockWindow


def fuzz_app_search(entry: App, query: str) -> App:
    p = fuzz.ratio(query.lower(), entry.keywords.lower())
    setattr(entry, "p", p)
    return entry


def gen_app(entry: App):
    return Widget.Button(
        Widget.Box(
            [
                Widget.Icon(entry.icon_name, 40, classname="app-icon"),
                Widget.Box(
                    [
                        Widget.Label(
                            entry.name,
                            classname="app-name",
                            halign="start",
                            xalign=0,
                            justify="left",
                            vexpand=True,
                        ),
                        (
                            Widget.Label(
                                entry.comment,
                                wrap=True,
                                classname="app-comment",
                                halign="start",
                                xalign=0,
                                justify="left",
                            )
                            if bool(entry.comment)
                            else None
                        ),
                    ],
                    "v",
                ),
            ],
            spacing=10,
        ),
        onclick=lambda: (entry.launch(), CloseLauncher()),
        classname="app-button",
    )


def AppLauncher(monitor=0):

    def wrapper(_: Widget.Entry):
        query = entry.get_text()
        app_list = Applications.query(query)
        # If the query isnt empty, use fuzzy search to order apps

        if query != "":
            app_list = list(map(lambda a: fuzz_app_search(a, query), app_list))
            app_list.sort(key=lambda app: getattr(app, "p"))

        entries = list(map(gen_app, app_list))

        tmp = []
        for i in entries:
            tmp.append(i)
            tmp.append(Widget.Separator(hexpand=True, classname="app-separator"))

        return container.set_children(tmp)

    def wrapper2(_: Widget.Entry):
        match = next((i for i in container.get_children()), None)

        if match:
            wait(50, entry.set_text, "")
            match.clicked()

    entry = Widget.Entry()
    container = Widget.Box(orientation="v", spacing=10)

    entry.connect("changed", wrapper)
    entry.connect("activate", wrapper2)

    entry.emit("changed")

    return Widget.Window(
        namespace=f"AppLauncher_{monitor}",
        position="center",
        size=[500, 600],
        focusable=True,
        children=Widget.Box(
            classname="applauncher",
            orientation="v",
            spacing=20,
            children=[
                Widget.Box(
                    [Widget.Icon("tool-zoom-symbolic", classname="icon"), entry],
                    classname="entry",
                    spacing=10,
                ),
                Widget.Scroll(container, hexpand=True, vexpand=True),
            ],
        ),
    )


AppLauncherWindow = AppLauncher()
StartButton: Widget.Button = next(
    i for i in DockWindow.get_children()[0].get_children() if hasattr(i, "applauncher")
)


def OpenLauncher():
    if not DockWindow.get_visible():
        DockWindow.open()
    if not AppLauncherWindow.get_visible():
        wait(150, AppLauncherWindow.open)
    StartButton.set_classname("dock-app-launcher active")


def CloseLauncher():
    if AppLauncherWindow.get_visible():
        AppLauncherWindow.close()
    if ActiveWindow.value != "" and DockWindow.get_visible():
        wait(150, DockWindow.close)

    StartButton.set_classname("dock-app-launcher")


def ToggleLauncher():
    if AppLauncherWindow.get_visible():
        return CloseLauncher()
    return OpenLauncher()
