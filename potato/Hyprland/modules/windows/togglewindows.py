from .newspanel import CloseNewsPanel, NewsPanelRevealer, OpenNewsPanel
from .overview import CloseOverview, OpenOverview, OverViewRevealer
from .quicksettings import (CloseControlPanel, ControlPanelRevealer,
                            OpenControlPanel)
from .startmenu import CloseStartMenu, OpenStartMenu, StartMenuRevealer


def CloseAll():
    CloseControlPanel()
    CloseStartMenu()
    CloseOverview()
    CloseNewsPanel()


def OpenAll():
    OpenControlPanel()
    OpenStartMenu()
    OpenNewsPanel()


def ToggleControlPanel():
    if ControlPanelRevealer.value:
        CloseControlPanel()
    else:
        CloseNewsPanel()
        CloseOverview()
        CloseStartMenu()
        OpenControlPanel()


def ToggleStartMenu():
    if StartMenuRevealer.value:
        CloseStartMenu()
    else:
        CloseControlPanel()
        CloseNewsPanel()
        CloseOverview()
        OpenStartMenu()


def ToggleOverview():
    if OverViewRevealer.value:
        CloseOverview()
    else:
        CloseControlPanel()
        CloseNewsPanel()
        CloseStartMenu()
        OpenOverview()


def ToggleNewsPanel():
    if NewsPanelRevealer.value:
        CloseNewsPanel()
    else:
        CloseOverview()
        CloseStartMenu()
        CloseControlPanel()
        OpenNewsPanel()
