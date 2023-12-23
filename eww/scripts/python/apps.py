#!/usr/bin/python

# # Base Code: juminai @ github
# # Mod Code: T0kyoB0y

import glob
import json
import os
from configparser import ConfigParser
from sys import argv as args

from _common import getIcon, shellOut, shellRun, updateEww

jsonPath = os.path.expanduser("~/.cache/eww/apps.json")
desktop_files = glob.glob(os.path.join("/usr/share/applications", "*.desktop"))

PREFERRED_APPS = []
WHITELISTED_APPS = ["Widget Factory", "Icon Browser"]
BLACKLISTED_APPS = ["system monitor"]
BLACKLISTED_SUBSTRINGS = ["avahi", "wayland"]


def get_desktop_entries(file_path):
    parser = ConfigParser()
    parser.read(file_path)
    app_name = parser.get("Desktop Entry", "Name")

    if (
        any(substring in app_name.lower() for substring in BLACKLISTED_SUBSTRINGS)
        or app_name.lower() in BLACKLISTED_APPS
        or parser.getboolean("Desktop Entry", "NoDisplay", fallback=False)
        and app_name not in WHITELISTED_APPS
    ):
        return None

    icon_path = getIcon(parser.get("Desktop Entry", "Icon", fallback=None)) or getIcon(
        "applets-template"
    )
    comment = parser.get("Desktop Entry", "Comment", fallback=None)

    if comment is None:
        comment = (
            parser.get("Desktop Entry", "Type", fallback=None)
            if not parser.get("Desktop Entry", "GenericName", fallback=None)
            else parser.get("Desktop Entry", "GenericName", fallback=None)
        )

    entry = {
        "name": app_name.title(),
        "icon": icon_path,
        "comment": comment,
        "desktop": f"gtk-launch {os.path.basename(file_path)}",
        "find": f"{app_name.title()} {app_name.title().lower()} {comment} {comment.lower()}",
    }
    return entry


def update_cache(all_apps, preferred_apps):
    data = {"apps": all_apps, "preferred": preferred_apps}
    with open(jsonPath, "w") as file:
        json.dump(data, file, indent=1)


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

    all_apps = sorted(all_apps, key=lambda x: x["name"].lower())

    update_cache(all_apps, preferred_apps)
    return {"apps": all_apps, "preferred": preferred_apps}


def filter_entries(entries, query):
    if query:
        query = query.lower()
        filtered_data = []

        for entry in entries["apps"]:
            name = entry["name"].lower()
            comment = entry["comment"].lower() if entry["comment"] else ""

            if any(keyword in name or keyword in comment for keyword in query.split()):
                filtered_data.append(entry)

        return filtered_data
    else:
        for entry in entries["apps"]:
            entry["name"] = entry["name"].title()
            entry["comment"] = entry["comment"]
        return entries["apps"]


def mathApp(query):
    try:
        result = eval(query)
        temp = "".join([f" {i} " if i in "+-*/" else i for i in query])
        return {
            "name": "Calculator",
            "icon": getIcon("accessories-calculator"),
            "comment": f"{temp} = {result}",
            "desktop": f"echo '{result}' | wl-copy && notify-send -i 'accessories-calculator' -a 'Calculator' 'Copied to Clipboard' '{result}'",
            "success": True,
        }
    except:
        return {"name": "", "icon": "", "comment": "", "desktop": "", "success": False}


def cmdApp(content):
    return {
        "name": "Run a Command",
        "icon": getIcon("gnome-term"),
        "comment": content,
        "desktop": f"{content[1:]}",
    }


def categorize_apps(apps):
    categorized_apps = []

    for i in range(ord("A"), ord("Z") + 1):
        letter = chr(i)
        apps_in_category = [app for app in apps if app["name"].startswith(letter)]
        keywords_list = [
            app["comment"].lower() + " " + app["name"].lower()
            for app in apps
            if app["name"].startswith(letter)
        ]
        keywords = " ".join(keywords_list)

        entry = {"category": letter, "keywords": keywords, "apps": apps_in_category}
        categorized_apps.append(entry)

    return categorized_apps


if __name__ == "__main__":
    if "--apps" in args:
        entries = get_cached_entries()
        categorized = categorize_apps(entries["apps"])
        updateEww("apps", {"apps": categorized, "preferred": entries["preferred"]})

    elif "--update" in args:
        updateEww("math", mathApp(shellOut("eww get apps_query")))
        updateEww("cmd", cmdApp(shellOut("eww get apps_query")))

    elif "--enter" in args:
        math = shellOut("eww get math")
        cmd = shellOut("eww get apps_query")

        if math["success"]:
            shellRun(math["desktop"], shell=True)

        elif cmd.startswith("/"):
            shellRun(shellOut("eww get cmd | jq -r .desktop"), shell=True)

        else:
            entries = get_cached_entries()
            query = args[2]
            filtered = filter_entries(entries, query)

            if filtered:
                shellRun(filtered[0]["desktop"].split(" "))
