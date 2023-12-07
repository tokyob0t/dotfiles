#!/usr/bin/python

import json
from sys import argv as args
from subprocess import PIPE
from subprocess import run as shellRun
from subprocess import getoutput as shellOut
from subprocess import Popen as shellPopen


from apps import get_gtk_icon as getIcon

def get_window_info(window_id):
    try:
        data = json.loads(shellOut(f"bspc query -T -n {window_id}"))
        client = data["client"]
        
        if str(client["className"]).lower() != "eww":
            id = data["id"]
            icon = getIcon(client["className"])
            name = client["className"].capitalize()
            floating = client["state"] == "floating"
            key = "floatingRectangle" if floating else "tiledRectangle"
            
            at = [client[key]["x"], client[key]["y"]]
            size = [client[key]["width"], client[key]["height"]]
        
            return {
                "window_id": str(id),
                "window_icon": str(icon),
                "window_name": str(name),
                "floating": floating,
                "at": at,
                "size": size
            } 
        else:
          pass

    except:
        pass


# Function to update Eww with window entries
def update_eww(entries):
    shellRun(["eww", "update", f"windows={json.dumps(entries)}"])

# Subscribe to window changes

if __name__ == "__main__":
    proc = shellPopen(["bspc", "subscribe", "node_add", "node_remove"], stdout=PIPE, text=True)

    if "--once" in args:

        print([{"workspace": str(workspace), "windows": [ get_window_info(window) for window in shellOut(f"bspc query -N -d {workspace}").split() if get_window_info(window)]} for workspace in shellOut("bspc query -D --names").split()])
        update_eww([{"workspace": str(workspace), "windows": [ get_window_info(window) for window in shellOut(f"bspc query -N -d {workspace}").split() if get_window_info(window)]} for workspace in shellOut("bspc query -D --names").split()])

    else:
        while True:
            _ = proc.stdout.readline()
            window_active = (json.loads(shellOut("bspc query -T -n $(bspc query -N -n focused)")))["id"]

            update_eww([{"workspace": str(workspace), "windows": [ get_window_info(window) for window in shellOut(f"bspc query -N -d {workspace}").split() if get_window_info(window)]} for workspace in shellOut("bspc query -D --names").split()])
