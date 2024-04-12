import json
import subprocess

from PotatoWidgets import Bash, HyprlandService, Listener, Poll, Variable, wait

# HyprlandService()
# this was before the creation of the hyprland service


def get_option(option):
    try:
        return json.loads(Bash.get_output(f"hyprctl getoption {option} -j"))
    except:
        return {}


def get_config():
    return {
        "kb_layout": get_option("input:kb_layout"),
        "gaps_in": get_option("general:gaps_in"),
        "gaps_out": get_option("general:gaps_out"),
        "border_size": get_option("general:border_size"),
    }


def get_windows(del_address=""):
    workspaces_info = [
        {"id": 1, "windows": []},
        {"id": 2, "windows": []},
        {"id": 3, "windows": []},
        {"id": 4, "windows": []},
        {"id": 5, "windows": []},
        {"id": 6, "windows": []},
        {"id": 7, "windows": []},
    ]

    for i in json.loads(Bash.get_output("hyprctl clients -j")):
        if (
            i["initialClass"]
            and i["address"] != del_address
            and i["class"]
            and i["title"]
        ):
            next(
                (
                    j["windows"]
                    for j in workspaces_info
                    if j["id"] == i["workspace"]["id"]
                ),
                [],
            ).append(
                {
                    "address": i["address"],
                    "at": i["at"],
                    "size": i["size"],
                    "initialClass": i["initialClass"],
                    "initialName": i["initialTitle"],
                    "name": i["title"],
                    "title": i["class"] or i["initialClass"],
                    "floating": i["floating"],
                }
            )
    return workspaces_info


def hypr():
    data = {"current_workspace": 1, "activewindow": "", "window_classnames": []}
    yield data

    with subprocess.Popen(
        [
            "socat",
            "-u",
            f"UNIX-CONNECT:/tmp/hypr/{Bash.get_env('HYPRLAND_INSTANCE_SIGNATURE')}/.socket2.sock",
            "-",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    ) as proc:
        for line in proc.stdout:
            line = line.replace("\n", "")

            if line.split(">>")[0] in [
                "movewindow",
                "activewindow",
                "workspace",
                "openwindow",
                "closewindow",
            ]:
                if "workspace>>" in line:
                    current = int(line.split(">>")[1])
                    data["current_workspace"] = current
                    current_workspace.set_value(current)

                elif "activewindow>>" in line:
                    data["activewindow"] = line.split(">>")[1].split(",")[0]

                    activewindow.set_value(data["activewindow"])

                elif "openwindow>>" in line or "movewindow>>" in line:
                    data["window_classnames"] = get_windows()
                    window_classnames.set_value(data["window_classnames"])

                elif "closewindow>>" in line:
                    # For some reason, get_windows() returns the recently closed window, so
                    data["window_classnames"] = get_windows(f"0x{line.split('>>')[1]}")
                    window_classnames.set_value(data["window_classnames"])

                yield data


CONF_FILE = Variable(get_config())

activewindow = Variable("")
current_workspace = Variable(1)
window_classnames = Variable(
    [
        {"id": 1, "windows": []},
        {"id": 2, "windows": []},
        {"id": 3, "windows": []},
        {"id": 4, "windows": []},
        {"id": 5, "windows": []},
        {"id": 6, "windows": []},
        {"id": 7, "windows": []},
    ]
)

HYPR_DATA = Listener(
    hypr,
    initial_value={"current_workspace": 1, "activewindow": "", "window_classnames": []},
)
