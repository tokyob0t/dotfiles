#!/usr/bin/python

import json
import time
from os.path import expanduser
from sys import argv as args
from _common import updateEww, shellCheckOut, shellOut, shellRun

TIMER_JSON_PATH = expanduser("~/.cache/eww/timer.json")


def load_timer():
    try:
        with open(TIMER_JSON_PATH, "r") as json_file:
            file_content = json_file.read().strip()
            if not file_content:
                default_timer_state = {"hour": 0, "min": 0, "sec": 0, "total_time": 0, "current_time": 0, "active": False}
                with open(TIMER_JSON_PATH, "w") as default_json_file:
                    json.dump(default_timer_state, default_json_file)
                return 0, 0, 0, 0, 0
            else:
                timer_state = json.loads(file_content)
                return (
                    int(timer_state.get("hour", 0)),
                    int(timer_state.get("min", 0)),
                    int(timer_state.get("sec", 0)),
                    int(timer_state.get("total_time", 0)),
                    int(float(timer_state.get("current_time", 0))),  # Convertir a entero después de parsear como float
                    timer_state.get("active", False)
                )
    except FileNotFoundError:
        # El archivo no existe, crea el estado predeterminado
        with open(TIMER_JSON_PATH, "w") as json_file:
            default_timer_state = {"hour": 0, "min": 0, "sec": 0, "total_time": 0, "current_time": 0, "active": False}
            json.dump(default_timer_state, json_file)
        return 0, 0, 0, 0, 0, False
    except json.JSONDecodeError:
        # Error al decodificar el JSON, crea el estado predeterminado
        with open(TIMER_JSON_PATH, "w") as json_file:
            default_timer_state = {"hour": 0, "min": 0, "sec": 0, "total_time": 0, "current_time": 0, "active": False}
            json.dump(default_timer_state, json_file)
        return 0, 0, 0, 0, 0, False




def save_timer():
    dict = {
        "hour": f"{h:02d}",
        "min": f"{m:02d}",
        "sec": f"{s:02d}",
        "total_time": total_seconds(),
        "current_time": total_seconds(),
        "active": False
    }
    updateEww("timer", dict)
    with open(TIMER_JSON_PATH, "w") as json_file:
        json.dump(dict, json_file)


def total_seconds():
    return h * 3600 + m * 60 + s



def handle_overflow_underflow():
    global s, m, h
    if s >= 60:
        s = 0
        m += 1
    elif s < 0:
        s = 59
        m -= 1

    if m >= 60:
        m = 0
        h += 1
    elif m < 0:
        m = 59
        h -= 1

    if h >= 24:
        h = 0
    elif h < 0:
        h = 23


def add_time(element):
    global s, m, h
    if element == "sec":
        if s < 59:
            s += 1
        elif s == 59:
            s = 0
            m += 1
    elif element == "min":
        if m < 59:
            m += 1
        elif m == 59:
            m = 0
            h += 1
    elif element == "hour":
        if h < 23:
            h += 1
    handle_overflow_underflow()
    save_timer()


def del_time(element):
    global s, m, h
    if element == "sec":
        if s > 0:
            s -= 1
        elif s == 0:
            s = 59
            m -= 1
    elif element == "min":
        if m > 0:
            m -= 1
        elif m == 0:
            m = 59
            h -= 1
    elif element == "hour":
        if h > 0:
            h -= 1
    handle_overflow_underflow()
    save_timer()


def set_time(element, value):
    global s, m, h
    if element == "sec":
        s = value
    elif element == "min":
        m = value
    elif element == "hour":
        h = value
    handle_overflow_underflow()
    save_timer()


def start_timer():
    try:
        global s, m, h
        total = total_seconds()
        remaining_seconds = total_seconds()

        while remaining_seconds > 0:
            time_remaining = remaining_seconds
            dict = {
                "hour": f"{time_remaining // 3600:02d}",
                "min": f"{(time_remaining % 3600) // 60:02d}",
                "sec": f"{time_remaining % 60:02d}",
                "total_time": total,
                "current_time": remaining_seconds,
                "active": True
                }
            updateEww("timer", dict)
            time.sleep(1)
            remaining_seconds -= 1

        for i in [h, m, s]:
            set_time(i, 0)
            
        notification_message = f"Timer finished!"
        shellRun(["notify-send", "Timer Notification", notification_message])
    except Exception as r:
        if r == KeyboardInterrupt:
            updateEww("timer_state", False)

if __name__ == "__main__":
    h, m, s, _, _, _ = load_timer()
    h = int(h)
    m = int(m)
    s = int(s)

    if "--up" in args:
        add_time(args[2])

    elif "--down" in args:
        del_time(args[2])

    elif "--set" in args:
        element_index = args.index("--set") + 1
        if element_index < len(args) - 1:
            element = args[element_index]
            value_index = element_index + 1
            try:
                value = int(args[value_index])
                set_time(element, value)
            except ValueError:
                exit(1)

        else:
            print("Missing value for the --set parameter.")
            exit(1)
        handle_overflow_underflow()
        save_timer()
    elif "--start" in args:
        start_timer()
