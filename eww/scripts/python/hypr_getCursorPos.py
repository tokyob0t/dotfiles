#!/usr/bin/python

import json
from subprocess import run as shellRun
from subprocess import getoutput as shellOut
from subprocess import Popen as shellPopen


def updateEww(data):
    shellRun(f"eww update jgMenu_cursorPos='{json.dumps(data)}'", shell=True)

if __name__ == "__main__":
    out = json.loads(shellOut("hyprctl cursorpos -j"))
    updateEww(out)
