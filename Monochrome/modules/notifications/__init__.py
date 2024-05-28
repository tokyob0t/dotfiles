import re

import marko
from PotatoWidgets import Bash, Widget, make_async
from PotatoWidgets.Services import Notification, NotificationsService

from ..common import get_symbolic

WIDTH = 350
HEIGHT = 75


@make_async
def parse_marko_async(callback=lambda v: v, text: str = "") -> None:
    text = marko.convert(text)

    replacements = {
        "<h1>": "<span size='xx-large'><b>",
        "</h1>": "</b></span>",
        "<h2>": "<span size='x-large'><b>",
        "</h2>": "</b></span>",
        "<h3>": "<span size='large'><b>",
        "</h3>": "</b></span>",
        "<h4>": "<span size='medium'><b>",
        "</h4>": "</b></span>",
        "<h5>": "<span size='small'><b>",
        "</h5>": "</b></span>",
        #
        "<code>": "<span background='#dde1e6' foreground='#232323' weight='600' font_family='JetBrainsMono Nerd Font' size='10pt'>",
        "</code>": "</span>",
        "<ins>": "<span underline='single'>",
        "</ins>": "</span>",
        "<strong>": "<b>",
        "</strong>": "</b>",
        "<em>": "<i>",
        "</em>": "</i>",
        "<p>": "",
        "</p>": "",
        # "\n": " ",
    }

    pattern = re.compile("|".join(re.escape(key) for key in replacements.keys()))
    text = pattern.sub(lambda x: replacements[x.group()], text)
    text = text.strip("\n")
    callback(text)
    return


def GenerateNotificationPopup(notif_object: Notification | None):
    if not notif_object:
        return

    notif_id = notif_object.id
    notif_title = notif_object.summary
    notif_content = notif_object.body
    notif_actions = notif_object.actions
    notif_urgency = notif_object.urgency

    match notif_object.name.lower():
        case "networkmanager" | "batterylevel":
            notif_glyph = notif_object.image
        case "screenshot":
            notif_glyph = "image-x-generic-symbolic"
        case "spotify":
            notif_glyph = "music-note-symbolic"
        case "discord" | "vencord":
            notif_glyph = "chat-bubble-empty-symbolic"
        case "notify-send":
            notif_glyph = "dialog-information-symbolic"
        case "microsoft-edge-dev" | "firefox":
            notif_glyph = "earth-symbolic"
        case _:
            notif_glyph = "application-x-executable-symbolic"

    title = Widget.Label(xalign=0, yalign=0.5, justify="start", maxchars=30)
    body = Widget.Label(xalign=0, yalign=0.5, justify="start", wrap=True)

    parse_marko_async(title.set_markup, notif_title)
    parse_marko_async(body.set_markup, notif_content)
    if notif_object.name.lower() == "screenshot":
        actions = [
            Widget.Button(
                Widget.Label("Open"),
                lambda: Bash.run_async(f"xdg-open {notif_object.image}"),
                classname="action-button",
                hexpand=True,
            ),
            Widget.Button(
                Widget.Label("Delete"),
                lambda: Bash.run_async(f"rm {notif_object.image}"),
                classname="action-button",
                hexpand=True,
            ),
        ]
    else:
        actions = list(
            map(
                lambda i: Widget.Button(
                    Widget.Label(i["label"]),
                    primaryrelease=lambda: NotificationsService.InvokeAction(
                        notif_id, i["id"]
                    ),
                    classname="action-button",
                    hexpand=True,
                ),
                notif_actions,
            )
        )

    return Widget.EventBox(
        attributes=lambda self: setattr(self, "id", notif_id),
        onhover=print,
        onhoverlost=print,
        children=Widget.Box(
            classname="notification-box " + notif_urgency,
            hexpand=True,
            size=[WIDTH, HEIGHT],
            children=[
                Widget.Box(
                    get_symbolic(notif_glyph),
                    classname="icon-container",
                    size=[75, 50],
                ),
                Widget.Box(
                    [
                        title,
                        body,
                        Widget.Box(
                            actions,
                            spacing=5,
                        ),
                    ],
                    spacing=5,
                    orientation="v",
                    classname="text-container",
                    hexpand=True,
                ),
            ],
        ),
    )


def NotificationPopupWindow(monitor: int = 0):
    def add_count() -> None:
        nonlocal notif_window

        notif_window.open()

        return setattr(notif_window, "count", getattr(notif_window, "count") + 1)

    def del_count() -> None:
        nonlocal notif_window

        setattr(notif_window, "count", getattr(notif_window, "count") - 1)

        if getattr(notif_window, "count") == 0:
            return notif_window.close()

    popups = Widget.Box(
        orientation="v", spacing=10, hexpand=True, vexpand=True, size=[WIDTH + 10, 0]
    )

    notif_window = Widget.Window(
        position="top",
        at={"top": 20},
        layer="overlay",
        namespace=f"NotificationPopup_{monitor}",
        attributes=lambda self: setattr(self, "count", 0),
        monitor=monitor,
        children=popups,
    )

    NotificationsService.connect(
        "popup",
        lambda _, id: (
            popups.add(GenerateNotificationPopup(NotificationsService.get_popup(id))),
            add_count(),
        ),
    )

    NotificationsService.connect(
        "dismissed",
        lambda _, id: (
            next(i.destroy() for i in popups.get_children() if getattr(i, "id") == id),
            del_count(),
        ),
    )


# no need to open/close ;we're using signals to auto-manage open/close
PopupsWindow = NotificationPopupWindow()
