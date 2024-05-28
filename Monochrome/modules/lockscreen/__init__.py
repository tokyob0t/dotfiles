import pam
from PotatoWidgets import Gdk, GLib, GtkLayerShell, Widget, make_async

p = pam.pam()


@make_async
def authenticate(paswd="", success=lambda _: (), failed=lambda _: ()) -> None:
    if p.authenticate("tokyob0t", paswd):
        success()
    else:
        failed()


def LockScreen(monitor=0):

    tmp_label = Widget.Label("󰌶", classname="nf-icon")
    entry = Widget.Entry(placeholder="Put y-your password here onii-chan", hexpand=True)
    entry.set_invisible_char("*")
    entry.set_visibility(False)

    entry.connect(
        "activate",
        lambda self: authenticate(
            self.get_text(),
            lambda: (
                tmp_window.close(),
                self.set_text(""),
            ),
            lambda: self.set_text(""),
        ),
    )

    tmp_window = Widget.Window(
        position="top left right bottom",
        layer="overlay",
        focusable=True,
        namespace="Lockscreen",
        children=Widget.Box(
            hexpand=True,
            vexpand=True,
            classname="lockscreen",
            children=Widget.Box(
                orientation="v",
                valign="center",
                halign="center",
                hexpand=True,
                vexpand=True,
                spacing=10,
                children=[
                    Widget.Box(
                        [
                            Widget.Box(
                                size=[200, 200],
                                classname="lockscreen-icon",
                                halign="center",
                            ),
                            Widget.Label("👉👈", css="font-size: 20px;"),
                        ],
                        "v",
                    ),
                    Widget.Label("Hewoo onii-chan"),
                    Widget.Box(
                        [
                            entry,
                            Widget.Button(
                                tmp_label,
                                primaryhold=lambda: (
                                    entry.set_visibility(True),
                                    tmp_label.set_text("󰛨"),
                                ),
                                primaryrelease=lambda: (
                                    entry.set_visibility(False),
                                    tmp_label.set_text("󰌶"),
                                ),
                            ),
                        ],
                        classname="lockscreen-entry",
                    ),
                ],
            ),
        ),
    )

    GtkLayerShell.set_exclusive_zone(tmp_window, -1)

    return tmp_window


MyLockScreen = LockScreen()
