#!/usr/bin/python

import json

from sys import argv as args
from subprocess import PIPE
from subprocess import run as shellRun
from subprocess import getoutput as shellOut
from subprocess import Popen as shellPopen

from apps import get_gtk_icon as getIcon


# Function to obtain window get_window_info(window)rmation including position and size
def test():
    data = json.loads(shellOut("bspc query -T -n $(bspc query -N -n focused)"))
    return data["client"]["className"]

def get_window_info(window_id):

    try:
        data = json.loads(shellOut(f"bspc query -T -n {window_id}"))

        dict = {
            "window_id": data["id"],
            "window_icon": getIcon(data["client"]["className"]),
            "window_name": data["client"]["className"].capitalize(),
            "focused": data["id"] == window_active,
            "floating": data["client"]["state"] == "floating",
            "at": [data["client"]["floatingRectangle"]["x"], data["client"]["floatingRectangle"]["y"]] if data["client"]["state"] == "floating" else [data["client"]["tiledRectangle"]["x"], data["client"]["tiledRectangle"]["y"]],
            "size": [data["client"]["floatingRectangle"]["width"], data["client"]["floatingRectangle"]["height"]] if data["client"]["state"] == "floating" else [data["client"]["tiledRectangle"]["width"], data["client"]["tiledRectangle"]["height"]]
        }

        return dict
    except:
        pass

def get_workspace_windows():
    list2 = []

    for workspace in shellOut("bspc query -D --names").split():
        list = []
        for window in shellOut(f"bspc query -N -d {workspace}").split():
            if get_window_info(window) != None:
                list.append(get_window_info(window))

        dict = {
            "workspace": str(workspace),
            "windows": list
        }
        list2.append(dict)
    return list2

# Function to update Eww with window entries
def update_eww(entries):
    shellRun(["eww", "update", f"windows={json.dumps(entries)}"])

# Subscribe to window changes
proc = shellPopen(["bspc", "subscribe", "node"], stdout=PIPE, text=True)

if __name__ == "__main__":

    if "--once" in args:
        print(get_workspace_windows())
        window_active = (json.loads(shellOut("bspc query -T -n $(bspc query -N -n focused)")))["id"]
        update_eww(get_workspace_windows())

    else:
        while True:
            _ = proc.stdout.readline()
            window_active = (json.loads(shellOut("bspc query -T -n $(bspc query -N -n focused)")))["id"]
            print(get_workspace_windows())
            update_eww(get_workspace_windows())

