#!/usr/bin/python

import json
import os
import sys
from _common import getIcon, update
from subprocess import getoutput as shellOut
from subprocess import Popen as shellPopen
from subprocess import PIPE

SIGNATURE = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")

def get_workspace_windows():
    entries = json.loads(shellOut("hyprctl clients -j"))
    workspaces_info = {}

    # Agregar workspaces del 1 al 6 manualmente
    for workspace_id in range(7):
        workspaces_info[workspace_id] = {
            "workspace": str(workspace_id),
            "windows": []
        }

    for entry in entries:
        workspace_id = entry["workspace"]["id"]

        if entry["class"] == "":
            continue
        
        if entry["class"].lower() == "vscodium":
            entry["class"] = "code"

        if workspace_id not in workspaces_info:
            workspaces_info[workspace_id] = {
                "workspace": str(workspace_id),
                "windows": []
            }

        workspaces_info[workspace_id]["windows"].append({
            "window_id": entry["pid"],
            "window_icon": getIcon(entry["class"]) or getIcon("applets-template"),
            "window_name": str(entry["class"].capitalize()),
            "floating": str(entry["floating"]).lower(),
            "at": entry["at"],
            "size": entry["size"]
        })
        

    sorted_workspaces = sorted(workspaces_info.values(), key=lambda x: int(x["workspace"]))

    return sorted_workspaces


if __name__ == "__main__":
    proc = shellPopen(["socat", "-u", f"UNIX-CONNECT:/tmp/hypr/{SIGNATURE}/.socket2.sock", "-"], stdout=PIPE, text=True)

    while True:
        _ = proc.stdout.readline()
        update("windows", get_workspace_windows())
