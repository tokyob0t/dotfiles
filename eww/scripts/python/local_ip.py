#!/usr/bin/python

from subprocess import run as shell
import json

def main():
    try:
        command = "ip addr show tun0 | grep -oP 'inet \K[\d.]+'"
        output = shell(command, shell=True, capture_output=True, text=True)
        ip_address = output.stdout.strip()

        if ip_address:
            status = "Connected"
        else:
            command = "ip addr show wlo1 | grep -oP 'inet \K[\d.]+'"
            out = shell(command, shell=True, capture_output=True, text=True)
            ip_address = out.stdout.strip()
            status = "Disconnected"

        module_output = {"text": f"{status}", "status": f"VPN Status: {status}", "IP": f"{ip_address}"}

        return json.dumps(module_output)
    except Exception as e:
        return json.dumps({"text": f"Error: {str(e)}"})

if __name__ == "__main__":
    print(main())
