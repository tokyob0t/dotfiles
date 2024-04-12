#!/usr/bin/python


from PotatoWidgets import DIR_CONFIG_POTATO, PotatoLoop

from modules import *


def main() -> None:
    BottomBar.open()
    Wallpaper.open()
    # OsdWindow.open()
    PotatoLoop(f"{DIR_CONFIG_POTATO}/Hyprland")


if __name__ == "__main__":
    main()
