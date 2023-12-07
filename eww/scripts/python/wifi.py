#!/usr/bin/python

from os import truncate
import subprocess
from subprocess import Popen, PIPE
import nmcli
import json
from _common import update, stringEscape
from sys import argv as args, exception
from colorama import Fore

wifiDict = {}

def signalIcon(value):
    if value >= 85:
        sigIcon = "󰤨"
    elif value >= 75:
        sigIcon = "󰤥"
    elif value >= 65:
        sigIcon = "󰤢"
    elif value >= 45:
        sigIcon = "󰤟"
    else:
        sigIcon = "󰤯"

    return sigIcon

def securityIcon(security, connected):
    if connected:
        return ""
    elif security in ["WPA2", "WPA3"]:
        return ""
    else:
        return ""

def scan_networks():
    wifiDict = {
        "scanned": [{
            "CLASS": "connected" if i.in_use else "locked" if i.security else "unlocked",
            "CONNECTED": i.in_use,
            "BSSID": i.bssid,
            "SSID": i.ssid,
            "SECURITY": i.security,
            "ICON": {
                "SIGNAL": signalIcon(i.signal),
                "SECURITY": securityIcon(i.security.split(" "), i.in_use),
            }
        }
            for i in nmcli.device.wifi()]
    }
    return wifiDict["scanned"]

def get_info():
    wifi = None

    for i in nmcli.device.wifi():
        if i.in_use:
            wifi = {
            "status": True,
            "name": i.ssid,
            "icon": signalIcon(i.signal)
            } 
    if not wifi:
        return {
            "status": False,
            "name": "Wi-Fi",
            "icon": "󰤮"
            }
    else:
        return wifi

def get_connected():
    out = nmcli.device.show_all()

    for i in out:

        if  i["GENERAL.TYPE"] in ["loopback", "wifi-p2p"]:
            continue

        elif "(connected)" in i["GENERAL.STATE"]:

            i["IP4.ADDRESS[1]"].split("/")[0]

        # print(i["GENERAL.TYPE"])
        # print(i["IP4.ADDRESS"])

if __name__=="__main__":

    nmcli.disable_use_sudo()
    
    if "--scan" in args:
        print(json.dumps(scan_networks()))

    elif "--info" in args:
        get_info()

    elif "--ip" in args:
        try:
            tun0 = nmcli.device.show("tun0")
            ip_address = tun0["IP4.ADDRESS[1]"]
            status = "Connected"
        except:
            out = nmcli.device.show_all()
            for i in out:
                if  i["GENERAL.TYPE"] in ["loopback", "wifi-p2p"] or "(connected)" not in i["GENERAL.STATE"]:
                    continue
                status = "Disconnected"
                ip_address = i["IP4.ADDRESS[1]"].split("/")[0]
                break

        print({"status": f"VPN Status: {status}", "IP": f"{ip_address}"})

    elif "--connected" in args:
        get_connected()

    elif "--test" in args:
        proc = subprocess.Popen(["nmcli", "monitor"], stdout=subprocess.PIPE, text=True)

        while True:
            line = proc.stdout.readline().replace("\n", "")


            if "p2p" in line:
                continue
            elif "disconnected" in line or "connected" in line:
                print(get_info())
                # print(Fore.RED + line, Fore.WHITE)
            else:
                # print(line)
                pass
                
    elif "--monitor" in args:
        proc = subprocess.Popen(["nmcli", "monitor"], stdout=subprocess.PIPE, text=True)

        while True:
            line = proc.stdout.readline().replace("\n", "")


            if "p2p" in line:
                continue
            elif "disconnected" in line or "connected" in line:
                update("wifiInfo", get_info())
            else:
                pass
