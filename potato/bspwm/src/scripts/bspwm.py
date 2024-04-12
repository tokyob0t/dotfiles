import json
import subprocess

from PotatoWidgets import Bash, Listener, Variable


def get_window_info(id, wp_id=-1):
    data = json.loads(Bash.get_output(f"bspc query --tree --node {id}"))
    data["id"] = id
    data["workspace"] = wp_id

    return data


def get_current_window(wp_id=-1):
    data = json.loads(Bash.get_output("bspc query --tree --node newest"))
    data["workspace"] = WorkspacesIdMap.get(str(id))
    return data


def get_workspaces_info():
    temp = WorkspaceInfo.value
    for workspace_id in Bash.get_output("bspc query --desktops --names").splitlines():
        next(workspace for workspace in temp if workspace["id"] == int(workspace_id))[
            "windows"
        ] = [
            get_window_info(i, WorkspacesIdMap.get(workspace_id, 0))
            for i in Bash.get_output(
                f"bspc query --nodes --desktop {workspace_id}"
            ).splitlines()
        ]

    return temp


def bspc():
    with subprocess.Popen(
        [
            "bspc",
            "subscribe",
            "desktop_focus",
            "node_add",
            "node_remove",
            "node_focus",
            "node_transfer",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    ) as proc:
        for line in proc.stdout:
            line = line.strip("\n")
            if "desktop_focus" in line:
                # desktop_focus <monitor_id> <desktop_id>

                CurrentWindowsInfo.value = get_current_window(line.split().pop(-1))

            elif "node_geometry" in line:
                # node_geometry <monitor_id> <desktop_id> <node_id> <node_geometry>
                # <node_geometry> = 1920x1080+0+0
                geometry = line.split().pop(-1)
                wp_id = line.split()[0]

            elif "node_add" in line or "node_remove" in line:
                # node_add <monitor_id> <desktop_id> <ip_id> <node_id>
                # node_remove <monitor_id> <desktop_id> <node_id>
                parts = line.split()
                desktop_id = WorkspacesIdMap.get(parts[2])
                node_id = parts[-1]
                temp = WorkspaceInfo.value
                win_data = next(
                    (i["windows"] for i in temp if i["id"] == desktop_id), []
                )

                if "node_add" in line:
                    win_data.append(get_window_info(node_id))
                elif "node_remove" in line:
                    win_data = [i for i in win_data if i["id"] != node_id]

                next(i for i in temp if i["id"] == desktop_id)["windows"] = win_data

                WorkspaceInfo.value = temp

            elif "node_transfer" in line:
                # node_transfer <src_monitor_id> <src_desktop_id> <src_node_id> <dst_monitor_id> <dst_desktop_id> <dst_node_id>
                pass
            # print(line)

            yield line


BSP_DATA = {}

CurrentWindowsInfo = Variable([])
WorkspaceInfo = Variable(
    [
        {"id": 1, "windows": []},
        {"id": 2, "windows": []},
        {"id": 3, "windows": []},
        {"id": 4, "windows": []},
        {"id": 5, "windows": []},
        {"id": 6, "windows": []},
        {"id": 7, "windows": []},
    ]
)


keys = subprocess.getoutput("bspc query --desktops").splitlines()
values = [i for i in range(1, len(keys) + 1)]
# values = subprocess.getoutput("bspc query --desktops --names").splitlines()

WorkspacesIdMap = {keys[i]: int(values[i]) for i in range(len(keys))}
WorkspaceInfo.value = get_workspaces_info()
_ = Listener(bspc)
