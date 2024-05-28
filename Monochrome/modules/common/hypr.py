from PotatoWidgets import Variable
from PotatoWidgets.Services.Hyprland import HyprlandService


class Workspace:
    def __init__(self, id) -> None:
        self.id = id
        self.windows = {}
        self.is_active = 0


class Window:
    def __init__(self, address: str, w_id: int, classname: str, title: str) -> None:
        self.address = address
        self.w_id = w_id
        self.classname = classname
        self.title = title


ActiveWorkspaces = Variable(list(map(Workspace, range(1, 8))))

ActiveWindow, _ = Variable(""), HyprlandService.connect(
    "activewindow", lambda _, *args: ActiveWindow.set_value(args[0])
)


def update_active_window(address: str):
    pass


def update_active_workspaces(id: int):
    i: Workspace

    for i in ActiveWorkspaces.value:
        if i.id == id:
            i.is_active = 1
        elif i.windows:
            i.is_active = 2
        else:
            i.is_active = 0

    return ActiveWorkspaces.set_value(ActiveWorkspaces.value)


def add_window(address: str, w_id, classname: str, title: str):
    w_id = int(w_id)
    tmp: list[Workspace] = ActiveWorkspaces.value

    next((i.windows for i in tmp if i.id == w_id), {})[address] = Window(
        address, w_id, classname, title
    )


def del_window(address: str):
    i: Workspace
    tmp = ActiveWorkspaces.value

    for i in tmp:
        if i.windows.get(address):
            del i.windows[address]
            ActiveWorkspaces.value = tmp
            return update_active_workspaces(-1)


HyprlandService.connect("workspace", lambda _, id: update_active_workspaces(int(id)))
HyprlandService.connect("openwindow", lambda _, *args: add_window(*args))
HyprlandService.connect("closewindow", lambda _, *args: del_window(*args))
