#!/usr/bin/env python3
import subprocess, json

def get_local_ip():
    try:
        command= "ip addr show tun0 | grep -oP 'inet \K[\d.]+'"
        output = subprocess.run(command,shell=True, capture_output=True, text=True)
        output = output.stdout

        if len(output) <= 0:
            output = 0
            command= "ip addr show wlo1 | grep -oP 'inet \K[\d.]+'"
            output = subprocess.run(command,shell=True, capture_output=True, text=True)
            output = output.stdout
            
            return output
        else:
            return output
    except:    
        return "192.168.0.0"
def send_content(text):
    text = text.replace("\n", "").replace(" ", "")
    module_output = {
    "text": text,
    "tooltip": f"Estás conectado a {text}",}
    return print(json.dumps(module_output))    


if __name__ == "__main__":
    send_content(get_local_ip())