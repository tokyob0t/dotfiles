from re import search as re_search
from re import sub as re_sub

from PotatoWidgets import Applications, Widget, lookup_icon

from .hypr import HYPR_DATA

# bar
PREFERRED_APPS = [
    "files",
    "zathura",
    # "neovim",
    "firefox web browser",
    "vscodium",
    # "hollow knight",
    # "wezterm",
    "kitty",
    "discord",
    "spotify",
]

# start menu
PINNED_APPS = PREFERRED_APPS + [
    "hollow knight",
    "discord",
    "pinta",
    "widget factory",
]


WHITELISTED_APPS = [
    "widget factory",
    "icon browser",
]


BLACKLISTED_APPS = [
    "gnome system monitor",
]

REPLACE_ICONS = {
    "org.wezfurlong.wezterm": "terminal",
    "kitty": "terminal",
    "discord": "webcord",
    "vencord": "webcord",
    "wezterm": "terminal",
    "zsh": "terminal",
    "mkdir": "terminal",
    "bash": "terminal",
    "vscodium": "vscode",
    "gtk settings": "application-x-addon-symbolic",
    "icon browser": "application-x-addon-symbolic",
    "nwg-look": "application-x-addon-symbolic",
}

for i in PREFERRED_APPS:
    Applications().add_preferred(i)

for i in BLACKLISTED_APPS:
    Applications().add_blacklist(i)

for i in WHITELISTED_APPS:
    Applications().add_whitelist(i)

_PINNED_APPS = [
    i
    for i in Applications().get_all()
    if i and any(j in i.keywords for j in PINNED_APPS)
]

_PREFERRED_APPS = [
    i
    for i in Applications().get_all()
    if i and any(j in i.keywords for j in PREFERRED_APPS)
]


def BottombarApps():
    return [
        (
            lambda app: Widget.Button(
                classname="module",
                valign="center",
                onclick=lambda: app.launch(),
                attributes=lambda self: self.bind(
                    HYPR_DATA,
                    lambda out: self.set_classname(
                        "module "
                        + (
                            "focused_module"
                            if out["activewindow"].lower() in app.keywords
                            and out["activewindow"] != ""
                            else ""
                        )
                    ),
                ),
                children=Widget.Box(
                    vexpand=True,
                    hexpand=True,
                    orientation="v",
                    children=[
                        (
                            Widget.Icon(
                                REPLACE_ICONS.get(app.icon_name, app.icon_name),
                                30,
                                halign="center",
                                valign="center",
                                hexpand=True,
                                vexpand=True,
                            )
                            if app.icon_name
                            else Widget.Image(
                                lookup_icon(
                                    REPLACE_ICONS.get(app.icon_name, app.icon_name),
                                ),
                                30,
                                halign="center",
                                valign="center",
                                hexpand=True,
                                vexpand=True,
                            )
                        ),
                        Widget.Separator(
                            hexpand=True,
                            halign="center",
                            valign="end",
                            classname="indicator",
                            attributes=lambda self: self.bind(
                                HYPR_DATA,
                                lambda out: self.set_classname(
                                    "indicator "
                                    + (
                                        "focused"
                                        if out["activewindow"].lower() in app.keywords
                                        and out["activewindow"] != ""
                                        else next(
                                            (
                                                "not_focused"
                                                for j in out["window_classnames"]
                                                if any(
                                                    s.lower() in app.keywords
                                                    for i in j["windows"]
                                                    for s in [
                                                        i["initialClass"],
                                                        i["initialName"],
                                                        i["title"],
                                                        i["name"],
                                                    ]
                                                )
                                            ),
                                            "",
                                        )
                                    )
                                ),
                            ),
                        ),
                    ],
                ),
            )
        )(app)
        for app in _PREFERRED_APPS
        if app
    ]


def StartMenuPinnedApps():
    temp = [
        (
            lambda i: Widget.Button(
                onclick=lambda: app.launch(),
                classname="module apps-pinned",
                halign="center",
                children=Widget.Box(
                    orientation="v",
                    halign="center",
                    valign="center",
                    hexpand=True,
                    vexpand=True,
                    children=[
                        (
                            Widget.Icon(
                                REPLACE_ICONS.get(app.icon_name, app.icon_name),
                                35,
                                valign="center",
                                halign="center",
                            )
                            if i.icon_name
                            else Widget.Image(
                                lookup_icon(
                                    REPLACE_ICONS.get(app.icon_name, app.icon_name)
                                ),
                                35,
                                valign="center",
                                halign="center",
                            )
                        ),
                        Widget.Label(
                            (
                                app.name
                                or app.generic_name  # Use app.name if available, otherwise use app.generic_name
                                if re_search(
                                    "[A-Z]", app.name or app.generic_name
                                )  # Check if any uppercase letter is present in app.name or app.generic_name
                                else (app.name or app.generic_name).title()
                            ),  # If no uppercase letters found, format the text as title case
                            maxchars=1,
                            valign="center",
                            halign="center",
                            xalign=0.5,
                            justify="center",
                        ),
                    ],
                ),
            )
        )(app)
        for app in _PINNED_APPS
    ]

    return [Widget.Box(temp[i : i + 6]) for i in range(0, len(temp), 6)]  # Matrix B)


def CategorizedApps() -> list:

    categorized_apps: dict = {}

    for app in Applications().get_all():
        if not app:
            continue

        category = app.name.lower()[0]

        if category not in categorized_apps:

            categorized_apps[category] = {
                "category": category,
                "keywords": " ".join(
                    [
                        re_sub(r"[^a-zA-Z0-9 ]", "", x.keywords)
                        for x in [
                            x
                            for x in Applications().get_all()
                            if x and x.name.lower().startswith(category)
                        ]
                    ]
                ),
                "apps": [],
            }

        categorized_apps[category]["apps"].append(app)
    return [categorized_apps[category] for category in sorted(categorized_apps.keys())]
