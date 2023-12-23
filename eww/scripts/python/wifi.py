#!/usr/bin/python

import subprocess
from sys import argv as args

import nmcli
from _common import getIcon, updateEww


def signalIcon(value):
    if value >= 75:
        return getIcon("network-wireless-signal-excellent-symbolic")
    elif value >= 45:
        return getIcon("network-wireless-signal-ok-symbolic")
    elif value >= 15:
        return getIcon("network-wireless-signal-weak-symbolic")
    elif value >= 0:
        return getIcon("network-wireless-signal-none-symbolic")
    else:
        return getIcon("network-wireless-offline-symbolic")


def securityIcon(security, connected):
    if connected:
        return ""
    elif "WPA" in security:
        return ""
    else:
        return ""


def chanIcon(chan):
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
            "CLASS": str,
            "CONNECTED": i.in_use,
            "BSSID": i.bssid,
            "SSID": ssid,
            "SECURITY": i.security,
            "KNOWN": ssid in knownwifiList,
            "ICON": {
                "SIGNAL": signalIcon(i.signal),
                "SECURITY": securityIcon(i.security, i.in_use),
                "CHAN": chanIcon(i.chan),
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
                "name": "Wired",
                "icon": getIcon("network-wired-symbolic"),
            }

    if nmcli.radio.wifi():
        for j in nmcli.device.wifi():
            if j.in_use:
                return {"status": True, "name": j.ssid, "icon": signalIcon(j.signal)}

    return {
        "status": nmcli.radio.wifi(),
        "name": "",
        "icon": signalIcon(0 if nmcli.radio.wifi() else -1),
    }


def local_ip():
    try:
        tun0 = nmcli.device.show("tun0")
        ip_address = tun0["IP4.ADDRESS[1]"]
        status = "Connected"
    except:
        status = "Disconnected"
        ip_address = "0.0.0.0"

        for i in nmcli.device.show_all():
            try:
                if (
                    i["GENERAL.TYPE"] in ["loopback", "wifi-p2p"]
                    or "unavailable" in i["GENERAL.STATE"]
                ):
                    continue
                else:
                    ip_address = i["IP4.ADDRESS[1]"].split("/")[0]
                    return {"status": f"VPN Status: {status}", "IP": f"{ip_address}"}
            except:
                continue

        ip_address = "0.0.0.0"
        return {"status": f"VPN Status: {status}", "IP": f"{ip_address}"}


def monitor(out=False):
    proc = subprocess.Popen(["nmcli", "monitor"], stdout=subprocess.PIPE, text=True)
    dict = {
        "wifi": {
            "status": False,
            "name": "",
            "icon": getIcon("network-wireless-offline-symbolic"),
        },
        "ip": {"status": "VPN Status: Disconnected", "IP": "0.0.0.0"},
    }
    updateEww("networkInfo", dict) if not out else None
    while True:
        line = proc.stdout.readline().replace("\n", "")
        dict["ip"] = local_ip()
        dict["wifi"] = get_connected()
        updateEww("networkInfo", dict) if not out else None

        if "p2p" in line:
            continue
        elif "disconnected" in line or "connected" in line:
            dict["ip"] = local_ip()
            dict["wifi"] = get_connected()
            updateEww("networkInfo", dict) if not out else None

        if out:
            print(line)
        else:
            continue


def connect(ssid, passw):
    if ssid in knownwifiList:
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


if __name__ == "__main__":
    nmcli.disable_use_sudo()

    knownwifiList = [i.name for i in nmcli.connection() if i.conn_type == "wifi"]

    if "--scan" in args:
        updateEww("networkList", scan_networks())
    elif "--ip" in args:
        print(local_ip())

    elif "--connect" in args:
        connect(args[2], args[3])

    elif "--connected" in args:
        updateEww("networkInfo", get_connected())

    elif "--monitor" in args:
        monitor()

    elif "--toggle" in args:
        if nmcli.radio.wifi():
            nmcli.radio.wifi_off()
        else:
            nmcli.radio.wifi_on()

    elif "--test" in args:
        print(connectionList)
