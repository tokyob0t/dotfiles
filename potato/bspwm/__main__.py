from PotatoWidgets import DIR_CONFIG_POTATO, PotatoLoop

from src import *


def main() -> None:

    Topbar.open()
    Desktop.open()
    PotatoLoop(f"{DIR_CONFIG_POTATO}/bspwm")


if __name__ == "__main__":
    main()
