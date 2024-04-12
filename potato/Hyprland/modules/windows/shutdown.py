from typing import List

from PotatoWidgets import Variable, Widget

OPTIONS = {
    "Shutdown": "Closes all apps and turns off the PC.",
    "Restart": "Closes all apps, turns off the PC, and then turns it on again.",
    "Sleep": "The PC remains on but consumes low power. Apps stay open, so when the pc wakes up, you're instantly back to where you left off.",
}


# https://lazka.github.io/pgi-docs/Gtk-3.0/classes/ComboBoxText.html
ShutdownSelection = Widget.ComboBox(list(OPTIONS.keys()), valign="end", hexpand=True)
ShutdownSelectionDesc = Variable("")

ShutdownSelection.connect(
    "changed",
    lambda self: ShutdownSelectionDesc.set_value(
        OPTIONS.get(
            self.get_active_text(),
        ),
    ),
)


def StupidFunction(texto: str, longitud_maxima: int = 55) -> str:
    palabras: List[str] = texto.split()
    lineas: List = []
    linea_actual: str = ""

    for palabra in palabras:
        if len(linea_actual) + len(palabra) + 1 <= longitud_maxima:
            if linea_actual:
                linea_actual += " "
            linea_actual += palabra
        else:
            lineas.append(linea_actual)
            linea_actual = palabra

    if linea_actual:
        lineas.append(linea_actual)

    return "\n".join(lineas)


ShutdownWindow = Widget.Window(
    disable_layer=True,
    size=[600, 300],
    children=Widget.Box(
        hexpand=True,
        vexpand=True,
        classname="shutdown-window",
        orientation="v",
        children=[
            Widget.Box(
                hexpand=True,
                classname="titlebar",
                children=[
                    Widget.Label(
                        "Shut Down Linux",
                        halign="start",
                        xalign=0,
                        justify="left",
                    ),
                ],
            ),
            Widget.Box(
                hexpand=True,
                vexpand=True,
                halign="center",
                valign="center",
                classname="content",
                orientation="v",
                children=[
                    Widget.Box(classname="top-section", valign="start"),
                    Widget.Box(
                        classname="mid-section",
                        vexpand=True,
                        valign="center",
                        spacing=20,
                        children=[
                            Widget.Icon("computer", 60),
                            Widget.Box(
                                vexpand=True,
                                halign="center",
                                valign="center",
                                size=[400, 120],
                                children=Widget.Box(
                                    orientation="v",
                                    hexpand=True,
                                    vexpand=True,
                                    spacing=10,
                                    children=[
                                        Widget.Label(
                                            "What do you want the fucking computer to do?",
                                            halign="start",
                                            xalign=0,
                                            justify="left",
                                        ),
                                        ShutdownSelection,
                                        Widget.Label(
                                            attributes=lambda self: self.bind(
                                                ShutdownSelectionDesc,
                                                lambda out: self.set_text(
                                                    StupidFunction(out)
                                                ),
                                            ),
                                            classname="selection-desc",
                                            valign="center",
                                            halign="start",
                                            xalign=0,
                                            justify="left",
                                            wrap=True,
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                    Widget.Box(
                        classname="bot-section",
                        spacing=20,
                        hexpand=True,
                        halign="end",
                        valign="end",
                        children=[
                            Widget.Button(
                                children=Widget.Label("OK"),
                                halign="end",
                                valign="end",
                            ),
                            Widget.Button(
                                children=Widget.Label("Cancel"),
                                halign="end",
                                valign="end",
                            ),
                            Widget.Button(
                                children=Widget.Label("Shut Up!"),
                                halign="end",
                                valign="end",
                            ),
                        ],
                    ),
                ],
            ),
        ],
    ),
)
