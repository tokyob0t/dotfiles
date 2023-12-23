#!/usr/bin/python

from _common import getIcon, updateEww
from sys import argv as args

if __name__=="__main__":
    if "--getDict" in args:

        dict = {}
        dict["media"] = {}
        dict["bluetooth"] = {}
        dict["arrow"] = {}
        dict["system"] = {}
        
        # Direction Arrows
        dict["arrow"]["up"] = getIcon("go-up-symbolic")
        dict["arrow"]["down"] = getIcon("go-down-symbolic")
        dict["arrow"]["left"] = getIcon("go-previous-symbolic")
        dict["arrow"]["right"] = getIcon("go-next-symbolic")

        # Various Trash Icon
        dict["nightlight"] = getIcon("night-light-symbolic")
        dict["supermenu"] = getIcon("view-grid-symbolic")
        dict["hambaga"] = getIcon("open-menu-symbolic")
        dict["hdd"] = getIcon("drive-harddisk-symbolic")

        # System Icons
        dict["system"]["shutdown"] = getIcon("system-shutdown-symbolic")
        dict["system"]["logout"] = getIcon("system-log-out-symbolic")
        dict["system"]["lock"] = getIcon("system-lock-screen-symbolic")
        dict["system"]["reboot"] = getIcon("system-reboot-symbolic")
        
        # Media Icons
        dict["media"]["prev"] = getIcon("media-skip-backward-symbolic")
        dict["media"]["next"] = getIcon("media-skip-forward-symbolic")
        dict["media"]["seek_prev"] = getIcon("media-seek-backward-symbolic")
        dict["media"]["seek_next"] = getIcon("media-seek-forward-symbolic")

        dict["media"]["pause"] = getIcon("media-playback-pause-symbolic")
        dict["media"]["start"] = getIcon("media-playback-start-symbolic")
        dict["media"]["stop"] = getIcon("media-playback-stop-symbolic")


        # BT ICONS
        dict["bluetooth"]["active"] = getIcon("bluetooth-active-symbolic")
        dict["bluetooth"]["inactive"] = getIcon("bluetooth-disabled-symbolic")

        updateEww("iconDict", dict)

    else:
        print(getIcon(args[1]))