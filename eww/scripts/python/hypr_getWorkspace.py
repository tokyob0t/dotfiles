#!/usr/bin/python

import json
import os
from subprocess import PIPE
from subprocess import run as shellRun
from subprocess import getoutput as shellOut
from subprocess import Popen as shellPopen


SIGNATURE = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")


def get_workspace():
    active_workspace_id = int(shellOut("hyprctl activeworkspace -j | jq .id"))
    entries = json.loads(shellOut("hyprctl workspaces -j"))

    result = [
        {"id": entry["id"], "state": "activeWorkspace" if entry["id"] == active_workspace_id else "inactiveWorkspace" if entry["windows"] > 0 else "emptyWorkspace"}
        for entry in entries
    ]

    result.extend(
        {"id": i, "state": "emptyWorkspace"} for i in range(1, 7) if not any(workspace["id"] == i for workspace in result)
    )


    return sorted(result, key=lambda x: x["id"])

if __name__ == "__main__":
    proc = shellPopen(["socat", "-u", f"UNIX-CONNECT:/tmp/hypr/{SIGNATURE}/.socket2.sock", "-"], stdout=PIPE, text=True)

    while True:
        line = proc.stdout.readline()

        if "workspace" not in line.split(">>"):
            continue

        # print(f"{json.dumps(get_workspace())}")
        shellRun(["eww", "update", f"workspaces={json.dumps(get_workspace())}"])