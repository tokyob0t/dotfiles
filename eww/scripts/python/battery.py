#!/usr/bin/python

import json
from subprocess import getoutput as shellOut
from subprocess import run as shellRun
from subprocess import Popen as shellPopen
from subprocess import PIPE
from _common import update

ICON = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
ICON_CHARGING = ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
BATTERY = "/org/freedesktop/UPower/devices/battery_BAT1"

dict = {
    "state": "",
    "percentage": 0,
    "icon": "",
    "class": "",
    "time_to": "Time to full: 1.5 hours"
}


def main():
    out = shellOut(f"upower -i {BATTERY}").splitlines()
    for i in range(len(out)):
        list = out[i].replace("  ", "").replace(",", "").split(":", 1)
        if len(list) < 2:
            continue

        key, value = list[0], list[1]

        if "state" == key:
            dict["state"] = value.strip().replace(" ", "").capitalize()

        elif "percentage" == key:

            dict["percentage"] = int(value.strip().replace(" ", "").replace("%", ""))

            if dict["state"].lower() in  ["charging", "pending-charge", "fully-charged"]:
                dict["class"] = "charging"
                dict["icon"] = ICON_CHARGING[min(dict["percentage"] // 10, len(ICON_CHARGING) - 1)]
            else:
                dict["class"] = "discharging"
                dict["icon"] = ICON[min(dict["percentage"] // 10, len(ICON) - 1)]

        elif "time to full" == key or "time to empty" == key:
            dict["time_to"] = str(f"Time to {'Full' if 'full' in key else 'Empty'}: {value.strip()}")
    return dict

if __name__ == "__main__":
        proc = shellPopen(["upower", "-m"], stdout=PIPE, text=True)
        while True:
            _ = proc.stdout.readline()
            update("battery", main())