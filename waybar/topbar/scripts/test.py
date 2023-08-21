#!/usr/bin/env python3

import sys
import json

def generate_module_output():
    text_content = "Hello, Waybar!"
    tooltip_content = "This is a custom module"
    icon_name = "icon-archivo"
    
    module_output = {
        "text": text_content,
        "tooltip": tooltip_content,
        "icon": icon_name,
    }

    return json.dumps(module_output)

if __name__ == "__main__":
    module_output = generate_module_output()
    print(module_output)
    sys.exit(0)
