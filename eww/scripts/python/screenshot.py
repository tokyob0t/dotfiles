#!/usr/bin/env python3


import os
from sys import argv as args
from datetime import datetime
import json
from _common import shellCheckOut, shellOut, shellRun

screenshot_dir = os.path.expanduser("~/Pictures/Screenshots")
file_name = f"Screenshot_{datetime.now().strftime('%m%d%H%M%S')}.png"
file_path = os.path.join(screenshot_dir, file_name)


def screenshot_wl(mode):
    if mode == "--sel":
        pass
        # command = ["grim", "-g", subprocess.check_output(["slurp", "-d"]).decode().strip(), file_path]
    elif mode == "--all":
        command = ["grim", file_path]
    elif mode == "--window":
        try:
            windows = json.loads(shellOut("hyprctl clients -j"))
            current_workspace = json.loads(shellOut("hyprctl activewindow -j | jq .workspace.id"))
            list = set([
                f"{i['at'][0]},{i['at'][1]} {i['size'][0]}x{i['size'][1]}" for i in windows if i['size'] != [0, 0] and 
                        i['at'] != [0, 0]
                    and
                        i['workspace']["id"] == current_workspace])
            print(list)

        except Exception as e:
            print(f"Error executing hyprctl: {e}")
            exit(1)

    else:
        print("Invalid mode. Use --sel to select a region, --all to capture the entire screen, or --window to select a window.")
        exit(1)

    if "WAYLAND_DISPLAY" in os.environ:
        shellRun(["wl-copy", "<", file_path])
screenshot_wl("--window")
