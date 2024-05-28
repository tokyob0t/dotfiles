import nmcli
from PotatoWidgets import Bash, Variable, Widget

nmcli.disable_use_sudo()


def signalicon(value):
    if value >= 80:
        return "network-wireless-signal-excellent-symbolic"
    elif value >= 60:
        return "network-wireless-signal-good-symbolic"
    elif value >= 40:
        return "network-wireless-signal-ok-symbolic"
    elif value >= 20:
        return "network-wireless-signal-weak-symbolic"
    else:
        return "network-wireless-signal-none-symbolic"


def securityicon(security, connected):
    if connected:
        return ""
    elif "wpa" in security:
        return ""
    return ""


def chanicon(chan):
    if 36 <= chan <= 165:
        return "󰬾󰫴"
    return "󰬻󰬽"


def scan_networks():
    unique_networks = set()
    network_list = []

    for i in nmcli.device.wifi():
        ssid = i.ssid.strip()

        if ssid in unique_networks or not ssid:
            continue

        str = ""

        if i.in_use:
            str = "connected"
        elif i.security:
            str = "locked"
        else:
            str = "unlocked"

        dict = {
            "class": str,
            "connected": i.in_use,
            "bssid": i.bssid,
            "ssid": ssid,
            "security": i.security,
            "known": ssid in knownwifilist,
            "icon": {
                "signal": signalicon(i.signal),
                "security": securityicon(i.security, i.in_use),
                "chan": chanicon(i.chan),
            },
        }

        network_list.append(dict)
        unique_networks.add(ssid)
    return network_list


def get_connected():
    for i in nmcli.connection():
        if i.conn_type == "loopback":
            break
        elif i.conn_type == "ethernet":
            return {
                "status": nmcli.radio.wifi(),
                "name": "wired",
                "icon": "network-wired-symbolic",
            }

    if nmcli.radio.wifi():
        for j in nmcli.device.wifi():
            if j.in_use:
                return {"status": True, "name": j.ssid, "icon": signalicon(j.signal)}

    return {
        "status": nmcli.radio.wifi(),
        "name": "",
        "icon": signalicon(0 if nmcli.radio.wifi() else -1),
    }


def local_ip():
    try:
        tun0 = nmcli.device.show("tun0")
        ip_address = tun0["ip4.address[1]"]
        status = "connected"
    except:
        status = "disconnected"
        ip_address = "0.0.0.0"

        for i in nmcli.device.show_all():
            try:
                if (
                    i["general.type"] in ["loopback", "wifi-p2p"]
                    or "unavailable" in i["general.state"]
                ):
                    continue
                else:
                    ip_address = i["ip4.address[1]"].split("/")[0]
                    return {"status": f"vpn status: {status}", "ip": f"{ip_address}"}
            except:
                continue

        ip_address = "0.0.0.0"
        return {"status": f"vpn status: {status}", "ip": f"{ip_address}"}


def monitor(line: str):
    line = line.strip("\n")

    if "p2p" in line:
        return
    elif "disconnected" in line or "connected" in line:

        data = network_info.value
        data["ip"] = local_ip()
        data["wifi"] = get_connected()
        network_info.value = data
        if "wlo1: connected" == line:
            Bash.run_async(
                "notify-send -a networkmanager -i {} 'Connection Successfull' 'Now connected to **{}**'".format(
                    data["wifi"]["icon"], data["wifi"]["name"].strip(" ")
                )
            )

    else:
        data = network_info.value
        data["ip"] = local_ip()
        data["wifi"] = get_connected()
        network_info.value = data


def connect(ssid, passw):
    if ssid in knownwifilist:
        try:
            nmcli.connection.up(ssid)
        except:
            return
    else:
        try:
            nmcli.device.wifi_connect(ssid=ssid, password=passw)
        except:
            if nmcli._exception.ConnectionActivateFailedException:
                nmcli.connection.delete(name=ssid)


def scan(self):
    self.set_value(scan_networks())


def ip(self):
    self.set_value(local_ip())


def connected(self):
    self.set_value(get_connected())


def toggle():
    if nmcli.radio.wifi():
        nmcli.radio.wifi_off()
        newIcon = "network-wireless-signal-none-symbolic"
    else:
        nmcli.radio.wifi_on()
        newIcon = "network-wireless-signal-excellent-symbolic"

    temp = network_info.value

    temp["wifi"]["icon"] = newIcon
    network_info.value = temp
    print(network_info)


network_info = Variable(
    {
        "wifi": {
            "status": False,
            "name": "Wi-Fi",
            "icon": "network-wireless-offline-symbolic",
        },
        "ip": {"status": "vpn status: disconnected", "ip": "0.0.0.0"},
    }
)

Bash.popen("nmcli monitor", stdout=monitor)


def NETWORK_ICON() -> Widget.Icon:
    return Widget.Icon(
        "network-wireless-signal-none-symbolic",
        20,
        classname="icon",
        attributes=lambda self: self.bind(
            network_info,
            lambda out: self.set_icon(out["wifi"]["icon"]),
        ),
    )
