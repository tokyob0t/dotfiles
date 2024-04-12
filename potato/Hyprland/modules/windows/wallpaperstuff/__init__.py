from typing import Callable, Dict, List

from magic import from_file as magic_from_file
from PotatoWidgets import (DIR_HOME, Applications, Bash, Gdk, Variable, Widget,
                           lookup_icon)

DIR_DESKTOP = DIR_HOME + "/Desktop"
REPLACE_ICONS = {"repositorios": "git"}
import subprocess

from ...utils._common import stringEscape


def get_type(path: str) -> str:
    if path.endswith(".desktop"):
        return "Desktop"
    try:
        return magic_from_file(path).split(",")[0]
    except IsADirectoryError:
        return "Directory"

    except:

        return "Empty"


def get_icon(path: str, _type: str):
    _type = _type.lower()
    name = path.replace(DIR_DESKTOP + "/", "")

    if ".desktop" in name:
        name = name.split(".", 1)[0]

    if "image" in _type:
        return path

    elif "python" in _type:
        return lookup_icon("text-x-python")

    elif "desktop" in _type:
        apps = Applications().query(name.lower())

        if apps:
            return lookup_icon(apps[0].icon_name)
    elif "directory" in _type:
        return lookup_icon("folder")
    else:

        return lookup_icon(REPLACE_ICONS.get(name, name))


def get_action(path: str, _type: str):
    _type = _type.lower()

    # if "desktop" in _type:
    #    return lambda: subprocess.Popen(["gtk-launch", path])
    # else:
    # Bash.run(f"xdg-open {file}")
    #    return lambda: subprocess.Popen(["xdg-open", path])
    return lambda: subprocess.Popen(
        ["xdg-open", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


def get_info(path: str):
    data = {}
    data["name"] = path.replace(DIR_DESKTOP + "/", "").split(".", 1)[0]
    data["path"] = path
    data["type"] = get_type(path)
    data["icon"] = get_icon(path, data["type"])
    data["launch"] = get_action(path.replace(" ", "\\ "), data["type"])
    return data


def get_deskfiles() -> List[str]:
    return [
        DIR_DESKTOP + "/" + i for i in Bash.get_output(f"ls {DIR_DESKTOP}").splitlines()
    ]


def desktop_entry(data: Dict[str, str]):
    def click_type(event: Gdk.EventButton, file: str):
        if event.type == Gdk.EventType.DOUBLE_BUTTON_PRESS:
            data.get("launch", lambda: ())()

    return Widget.Button(
        primaryhold=lambda event: click_type(event, data["path"]),
        valign="center",
        halign="center",
        size=[50, 50],
        children=Widget.Box(
            orientation="v",
            children=[
                Widget.Box(
                    size=[50, 50],
                    children=Widget.Image(
                        data["icon"],
                        40,
                        hexpand=True,
                        vexpand=True,
                        valign="center",
                        halign="center",
                    ),
                ),
                Widget.Label(
                    data["name"],
                    wrap=True,
                    maxchars=13,
                    halign="center",
                    valign="center",
                    xalign=0.5,
                    justify="center",
                ),
            ],
        ),
    )


DESKTOP_ENTRIES = [desktop_entry(get_info(i)) for i in get_deskfiles()]


DESKTOP_ENTRIES = [
    Widget.Box(children=DESKTOP_ENTRIES[i : i + 10], orientation="v", spacing=5)
    for i in range(0, len(DESKTOP_ENTRIES), 10)
]
