#!/usr/bin/python


import glob
import sys
import os
import json
import subprocess
import gi
from configparser import ConfigParser

from math import sqrt, pi, sin, cos, tan

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk



# Path to the JSON file used for caching application data
jsonPath = os.path.expanduser("~/.cache/eww/apps.json")
desktop_files = glob.glob(os.path.join("/usr/share/applications", "*.desktop"))

# List of preferred (favorite) applications
PREFERRED_APPS = []

# List of applications to be blacklisted (hidden)
BLACKLISTED_APPS = []

# List of substrings used to blacklist applications (hidden)
BLACKLISTED_SUBSTRINGS = [
    "avahi",
    "wayland"
]

def get_gtk_icon(icon_name):
    if icon_name is not None:
        theme = Gtk.IconTheme.get_default()

        for name in [icon_name.lower(), icon_name.capitalize(), icon_name]:
            icon_info = theme.lookup_icon(name, 128, 0)
            if icon_info is not None:
                return icon_info.get_filename()

    return None

def mathApp(content):
    icon_path = get_gtk_icon("accessories-calculator")

    entry = {
        "name": "Calculator",
        "icon": icon_path,
        "comment": content,
        "desktop": f"--version; echo '{content}' | xclip -selection clipboard",
    }
    return entry

def math(query):
    try:
        result = eval(query)
        temp = ''.join([f" {i} " if i in "+-*/" else i for i in query])

        return mathApp(f"{temp} = {result}")

    except:
        return None


def get_desktop_entries(file_path):
    parser = ConfigParser()
    parser.read(file_path)
    app_name = parser.get("Desktop Entry", "Name")

    if any(substring in app_name.lower() for substring in BLACKLISTED_SUBSTRINGS) or app_name in BLACKLISTED_APPS or parser.getboolean("Desktop Entry", "NoDisplay", fallback=False):
        return None

    icon_path = get_gtk_icon(parser.get("Desktop Entry", "Icon", fallback=None))
    comment = parser.get("Desktop Entry", "Comment", fallback=None)

    if comment is None:
        comment = parser.get("Desktop Entry", "Type", fallback=None) if parser.get("Desktop Entry", "GenericName", fallback=None) == None else parser.get("Desktop Entry", "GenericName", fallback=None)

    entry = {
        "name": app_name.capitalize(),
        "icon": icon_path,
        "comment": comment,
        "desktop": os.path.basename(file_path),
    }
    return entry

def update_cache(all_apps, preferred_apps):
    data = {"apps": all_apps, "preferred": preferred_apps}
    with open(jsonPath, "w") as file:
        json.dump(data, file, indent=2)

def get_cached_entries():
    if os.path.exists(jsonPath):
        with open(jsonPath, "r") as file:
            try:
                return json.load(file)
            except json.JSONDecodeError:
                pass

    all_apps = []
    preferred_apps = []


    for file_path in desktop_files:
        entry = get_desktop_entries(file_path)
        if entry is not None:
            all_apps.append(entry)
            if entry["name"].lower() in PREFERRED_APPS:
                preferred_apps.append(entry)

    # Sort applications alphabetically by name
    all_apps = sorted(all_apps, key=lambda x: x["name"].lower())

    update_cache(all_apps, preferred_apps)
    return {"math": [], "apps": all_apps, "preferred": preferred_apps}

def filter_entries(entries, query):
    query = query.lower()
    filtered_data = []

    for entry in entries["apps"]:
        name = entry["name"].lower()
        comment = entry["comment"].lower() if entry["comment"] else ""

        # Realiza una búsqueda por palabras clave en el nombre y el comentario
        if any(keyword in name or keyword in comment for keyword in query.split()):
            filtered_data.append(entry)

    return filtered_data

def update_eww(entries):
    subprocess.run(["eww", "update", "apps={}".format(json.dumps(entries))])

if __name__ == "__main__":
    entries = get_cached_entries()

    query = sys.argv[2] if len(sys.argv) > 2 and sys.argv[1] == "--query" else None
    result = [math(query)] if math(query) != None else []

    if query is not None:
        filtered = filter_entries(entries, query)
        update_eww({"math": result,"apps": filtered, "preferred": entries["preferred"]})

    else:
        update_eww(entries)
