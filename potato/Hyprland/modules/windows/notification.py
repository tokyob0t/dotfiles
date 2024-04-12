from PotatoWidgets import (Notification, NotificationsService, Widget,
                           lookup_icon, wait)


def GenerateNotificationPopup(notif: Notification):

    if not notif:
        return

    if notif.name.lower() in ["screenshot", "flameshotgui"]:
        glyph = lookup_icon("view-fullscreen-symbolic")

    elif notif.name.lower() in ["vencorddesktop", "betterdiscord"]:
        glyph = lookup_icon("webcord")

    elif notif.name.lower() in ["linux update"]:
        glyph = lookup_icon("software-update-available-symbolic")

    else:
        glyph = lookup_icon(notif.name) or lookup_icon("view-grid-symbolic")
    CloseButton = Widget.Button(
        Widget.Label("", classname="nf-icon closebutton"),
        valign="center",
        halign="end",
        hexpand=True,
        classname="closebutton",
        onclick=lambda: (
            wait(500, notif.dismiss),
            Container.set_classname("notification-revealer"),
        ),
    )

    Container = Widget.Box(
        attributes=lambda self: (
            setattr(self, "id", notif.id),
            wait(100, self.set_classname, "notification-revealer active"),
        ),
        classname="notification-revealer inactive",
        size=[400, 0],
        children=Widget.Box(
            orientation="v",
            classname="notification-box",
            spacing=10,
            hexpand=True,
            vexpand=True,
            children=[
                Widget.Box(
                    hexpand=True,
                    classname="notif-top-section",
                    children=[
                        Widget.Box(
                            valign="center",
                            halign="start",
                            spacing=10,
                            children=[
                                Widget.Image(glyph, 18),
                                Widget.Label(notif.name.title()),
                            ],
                        ),
                        CloseButton,
                    ],
                ),
                Widget.Box(
                    classname="notif-mid-section",
                    spacing=10,
                    children=[
                        (
                            Widget.Image(notif.image, 50)
                            if notif.image.endswith(".svg")
                            else (
                                Widget.Box(
                                    classname="notif-image",
                                    size=60,
                                    css=f"""
                                        background-size: cover;
                                        background-repeat: no-repeat;
                                        background-position: center;
                                        border-radius: 7.5px;
                                        background-image: url("{notif.image}");
                                    """,
                                )
                                if notif.image != ""
                                else False
                            )
                        ),
                        Widget.Box(
                            orientation="v",
                            children=[
                                Widget.Label(
                                    notif.summary,
                                    halign="start",
                                    xalign=0,
                                    wrap=True,
                                    maxchars=35,
                                    classname="notif-summary",
                                ),
                                Widget.Label(
                                    notif.body,
                                    halign="start",
                                    xalign=0,
                                    justify="left",
                                    wrap=True,
                                    classname="notif-body",
                                    maxchars=100 if len(notif.body) > 100 else -1,
                                ),
                            ],
                        ),
                    ],
                ),
            ],
        ),
    )

    return Container


notifservice = NotificationsService()

NotificationPopupWindow = Widget.Window(
    position="bottom right",
    layer="overlay",
    size=[0, 0],
    attributes=lambda self: (
        notifservice.connect(
            "popups",
            lambda _, c: (
                self.set_visible(True)
                if bool(c)
                else wait(
                    500, self.set_visible, False
                )  # wait  500 ms before closing the window, due to the animation
            ),
        )
    ),
    children=Widget.Box(
        orientation="v",
        hexpand=True,
        vexpand=True,
        valign="end",
        attributes=lambda self: (
            notifservice.connect(
                "popup",
                # https://lazka.github.io/pgi-docs/Gtk-3.0/classes/Container.html#Gtk.Container.add
                lambda service, id: self.add(
                    GenerateNotificationPopup(service.get_popup(id))
                ),
            ),
            notifservice.connect(
                "dismissed",
                # https://lazka.github.io/pgi-docs/Gtk-3.0/classes/Container.html#Gtk.Container.remove
                lambda _, id: (
                    wait(
                        500,
                        self.remove,
                        next((i for i in self.get_children() if i.id == id), None),
                    ),
                    next(
                        (
                            i.set_classname("notification-revealer inactive")
                            for i in self.get_children()
                            if i.id == id
                        ),
                        None,
                    ),
                ),
            ),
        ),
    ),
)
