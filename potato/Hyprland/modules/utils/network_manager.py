#!/usr/bin/python

import subprocess

import nmcli
from PotatoWidgets import Listener, Poll, Variable, Widget

nmcli.disable_use_sudo()


def signalicon(value):
    if value >= 75:
        return "network-wireless-signal-excellent-symbolic"
    elif value >= 45:
        return "network-wireless-signal-ok-symbolic"
    elif value >= 15:
        return "network-wireless-signal-weak-symbolic"
    elif value >= 0:
        return "network-wireless-signal-none-symbolic"
    else:
        return "network-wireless-offline-symbolic"


def securityicon(security, connected):
    if connected:
        return ""
    elif "wpa" in security:
        return ""
    else:
        return ""


def chanicon(chan):
    if 36 <= chan <= 165:
        return "󰬾󰫴"
    else:
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
                    or "unavailable" == i["general.state"]
                ):
                    continue
                else:
                    ip_address = i["ip4.address[1]"].split("/")[0]
                    return {"status": f"vpn status: {status}", "ip": f"{ip_address}"}
            except:
                continue

        ip_address = "0.0.0.0"
        return {"status": f"vpn status: {status}", "ip": f"{ip_address}"}


def monitor():
    dict = {
        "wifi": {
            "status": False,
            "name": "",
            "icon": Widget.Icon("network-wireless-offline-symbolic"),
        },
        "ip": {"status": "vpn status: disconnected", "ip": "0.0.0.0"},
    }
    yield dict
    with subprocess.Popen(
        ["nmcli", "monitor"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    ) as proc:
        for line in proc.stdout:
            if "p2p" in line:
                continue
            elif "disconnected" in line or "connected" in line:
                dict["ip"] = local_ip()
                dict["wifi"] = get_connected()
            else:
                dict["ip"] = local_ip()
                dict["wifi"] = get_connected()
            yield dict


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
    nmcli.radio.wifi_off() if nmcli.radio.wifi() else nmcli.radio.wifi_on()


network_info = Listener(monitor)
