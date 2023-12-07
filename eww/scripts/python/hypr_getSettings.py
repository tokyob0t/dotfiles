#!/usr/bin/python
import subprocess
import json
from subprocess import run as shellRun
from subprocess import getoutput as shellOut
from subprocess import Popen as shellPopen

def get_options():
    layout = shellOut("hyprctl getoption general:layout -j | jq -r -c .str")
    gaps_in = shellOut("hyprctl getoption general:gaps_in -j | jq -r -c .int")
    gaps_out = shellOut("hyprctl getoption general:gaps_out -j | jq -r -c .int")

    border_size = shellOut("hyprctl getoption general:border_size -j | jq -r -c .int")
    force_no_accel = shellOut("hyprctl getoption input:force_no_accel -j | jq -r -c .int")
    input_sensitivity = shellOut("hyprctl getoption input:sensitivity -j | jq -r -c .float")
    touchpad_disable_while_typing = shellOut("hyprctl getoption input:touchpad:disable_while_typing -j | jq -r -c .int")
    touchpad_clickfinger_behavior = shellOut("hyprctl getoption input:touchpad:clickfinger_behavior -j | jq -r -c .int")

    rounding = shellOut("hyprctl getoption decoration:rounding -j | jq -r -c .int")
    blur = shellOut("hyprctl getoption decoration:blur:enabled -j | jq -r -c .int")
    blur_size = shellOut("hyprctl getoption decoration:blur:size -j | jq -r -c .int")
    blur_passes = shellOut("hyprctl getoption decoration:blur:passes -j | jq -r -c .int")
    blur_xray = shellOut("hyprctl getoption decoration:blur:xray -j | jq -r -c .int")


    options = {
        "layout": layout,
        "rounding": rounding,
        "gaps": {
            "in": gaps_in,
            "out": gaps_out
        },
        "border_size": border_size,
        "force_no_accel": force_no_accel,
        "input_sensitivity": input_sensitivity,
        "touchpad_disable_while_typing": touchpad_disable_while_typing,
        "touchpad_clickfinger_behavior": touchpad_clickfinger_behavior,
        "blur": {
            "enabled": blur,
            "size": blur_size,
            "passes": blur_passes,
            "xray": blur_xray
            }
        }

    return options

options = get_options()
print(json.dumps(options))
