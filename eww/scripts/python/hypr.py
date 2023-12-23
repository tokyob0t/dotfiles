#!/usr/bin/python

import json
import os
from _common import getIcon, updateEww, shellOut, shellPopen
from sys import argv as args
from time import sleep
SIGNATURE = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")


def get_windows():
    entries = shellOut("hyprctl clients -j")
    workspaces_info = {}

    for workspace_id in range(1, 7):
        workspaces_info[workspace_id] = {"workspace": str(workspace_id), "windows": []}

    for entry in entries:
        workspace_id = entry["workspace"]["id"]

        if entry["class"] == "":
            continue

        if entry["class"].lower() == "vscodium":
            entry["class"] = "code"

        if workspace_id not in workspaces_info:
            workspaces_info[workspace_id] = {
                "workspace": str(workspace_id),
                "windows": [],
            }

        workspaces_info[workspace_id]["windows"].append(
            {
                "window_id": entry["pid"],
                "window_icon": getIcon(entry["class"]) or getIcon("applets-template"),
                "window_name": str(entry["class"].capitalize()),
                "floating": str(entry["floating"]).lower(),
                "at": entry["at"],
                "size": entry["size"],
            }
        )

    return sorted(workspaces_info.values(), key=lambda x: int(x["workspace"]))


def get_workspaces():
    active_workspace_id = int(shellOut("hyprctl activeworkspace -j | jq .id"))
    entries = shellOut("hyprctl workspaces -j")

    list = [
        {
            "id": entry["id"],
            "state": "activeWorkspace"
            if entry["id"] == active_workspace_id
            else "inactiveWorkspace"
            if entry["windows"] > 0
            else "emptyWorkspace",
        }
        for entry in entries
    ]

    list.extend(
        {"id": i, "state": "emptyWorkspace"}
        for i in range(1, 8)
        if not any(workspace["id"] == i for workspace in list)
    )

    return sorted(list, key=lambda x: x["id"])


if __name__ == "__main__":
    if "--getCursor" in args:
        updateEww("jgMenu_cursorPos", shellOut("hyprctl cursorpos -j"))

    elif "--getWindows" in args or "--getWorkspaces" in args:
        updateEww(
            "workspaces",
            [
                {"id": 1, "state": "emptyWorkspace"},
                {"id": 2, "state": "emptyWorkspace"},
                {"id": 3, "state": "emptyWorkspace"},
                {"id": 4, "state": "emptyWorkspace"},
                {"id": 5, "state": "emptyWorkspace"},
                {"id": 6, "state": "emptyWorkspace"},
                {"id": 7, "state": "emptyWorkspace"}
            ]
        )
        updateEww(
            "windows",
            [
                {"id": 1, "windows": []},
                {"id": 2, "windows": []},
                {"id": 3, "windows": []},
                {"id": 4, "windows": []},
                {"id": 5, "windows": []},
                {"id": 6, "windows": []},
                {"id": 7, "windows": []}
            ]
        )
        proc = shellPopen(["socat", "-u", f"UNIX-CONNECT:/tmp/hypr/{SIGNATURE}/.socket2.sock", "-"])

        while True:
            line = proc.stdout.readline().split(">>")

            if "workspace" in line:
                updateEww("workspaces", get_workspaces())
            elif "closewindow" in line or "openwindow" in line:
                updateEww("windows", get_windows())
            sleep(0.025)