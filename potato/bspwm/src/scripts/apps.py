import json
import subprocess
from collections import defaultdict
from configparser import ConfigParser
from os import listdir
from os.path import expanduser

from PotatoWidgets import Widget, lookup_icon

jsonPath = expanduser("~/.cache/potatowidgets/apps.json")

desktop_files_dir = "/usr/share/applications"
desktop_files = [
    f"{desktop_files_dir}/{f}"
    for f in listdir(desktop_files_dir)
    if f.endswith(".desktop")
]

PREFERRED_APPS = [
    "files",
    "zathura",
    # "neovim",
    "firefox web browser",
    "vscodium",
    # "hollow knight",
    "wezterm",
    "discord",
    "spotify",
]

PINNED_APPS = [
    "zathura",
    "files",
    "firefox web browser",
    "vscodium",
    "hollow knight",
    "neovim",
    "wezterm",
    "discord",
    "spotify",
    "pinta",
    "widget factory",
]


WHITELISTED_APPS = [
    "widget factory",
    "icon browser",
]

BLACKLISTED_APPS = [
    "gnome system monitor",
    # "kitty",
    # "ranger",
    # "alacritty",
]
BLACKLISTED_SUBSTRINGS = [
    "wayland",
]

REPLACE_ICONS = {
    # "firefox web browser": "microsoft-edge",
    "org.wezfurlong.wezterm": "terminal",
    "discord": "webcord",
    "wezterm": "terminal",
    "zsh": "terminal",
    "mkdir": "terminal",
    "bash": "terminal",
    "vscodium": "vscode",
    "gtk settings": "application-x-addon-symbolic",
    "icon browser": "application-x-addon-symbolic",
    "nwg-look": "application-x-addon-symbolic",
}


def get_desktop_entries(file_path=jsonPath):
    parser = ConfigParser()
    parser.read(file_path)
    app_name = parser.get("Desktop Entry", "Name")
    app_lower = app_name.lower()

    if (
        any(substring in app_lower for substring in BLACKLISTED_SUBSTRINGS)
        or app_lower in BLACKLISTED_APPS
        or parser.getboolean("Desktop Entry", "NoDisplay", fallback=False)
        or app_lower in WHITELISTED_APPS
    ):
        return None

    app_icon = parser.get("Desktop Entry", "Icon", fallback="").lower()
    app_icon_path = lookup_icon(
        REPLACE_ICONS.get(app_lower, app_icon), fallback="view-grid-symbolic"
    )

    app_comment = (
        parser.get("Desktop Entry", "Comment", fallback="").lower()
        or parser.get("Desktop Entry", "GenericName", fallback="").lower()
    )
    app_type = parser.get("Desktop Entry", "Type", fallback="")

    app_categories = (
        parser.get("Desktop Entry", "Categories", fallback="").lower().split(";")
    )
    app_keywords = (
        parser.get("Desktop Entry", "Keywords", fallback="").lower().split(";")
    )

    app_desktop = [file_path.split("/").pop(-1)]

    entry = {
        "name": app_name.title(),
        "icon": app_icon_path,
        "comment": app_comment,
        "desktop": app_desktop,
        "type": app_type or app_categories[0].capitalize() or app_comment,
        "category": app_categories[0].capitalize() or app_type,
        "find": f"{app_lower} {app_comment} {app_icon if not app_icon.endswith('.png') and not app_icon.endswith('.svg') else ''} {' '.join(app_categories)} {' '.join(app_keywords)}",
    }

    return entry


def update_cache(all_apps, preferred_apps, pinned_apps):
    data = {"apps": all_apps, "preferred": preferred_apps, "pinned": pinned_apps}
    with open(jsonPath, "w") as file:
        json.dump(data, file, indent=1)


def get_apps():
    all_apps = []
    preferred_apps = []
    pinned_apps = []

    for file_path in desktop_files:
        entry = get_desktop_entries(file_path)
        if entry is not None:
            all_apps.append(entry)
            if entry["name"].lower() in PREFERRED_APPS:
                preferred_apps.append(entry)
            if entry["name"].lower() in PINNED_APPS:
                pinned_apps.append(entry)

    preferred_apps = sorted(
        preferred_apps, key=lambda x: PREFERRED_APPS.index(x["name"].lower())
    )
    pinned_apps = sorted(
        pinned_apps, key=lambda x: PINNED_APPS.index(x["name"].lower())
    )
    all_apps = sorted(all_apps, key=lambda x: x["name"].lower())

    apps_by_letter = defaultdict(list)
    for app in all_apps:
        first_letter = app["name"][0].lower()
        apps_by_letter[first_letter].append(app)

    categorized_apps = []
    for letter, apps in sorted(apps_by_letter.items()):
        section = {
            "category": letter.upper(),
            "keywords": " ".join(
                word.lower()
                for app in apps
                for word in set(app_word for app_word in app["find"].split())
                if word != " "
            ),
            "apps": apps,
        }

        categorized_apps.append(section)

    update_cache(categorized_apps, preferred_apps, pinned_apps)
    return {
        "apps": categorized_apps,
        "preferred": preferred_apps,
        "pinned": pinned_apps,
    }


apps = get_apps()
