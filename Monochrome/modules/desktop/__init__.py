from PotatoWidgets import (DIR_HOME, Bash, Gdk, Gtk, GtkLayerShell, Widget,
                           lookup_icon)

from ..common import get_symbolic
from .players import MediaWidget


def Wall(monitor=0):
    def wrapper(
        Widget: Gtk.Widget,
        DragContext: Gdk.DragContext,
        X: int,
        Y: int,
        SelectionData: Gtk.SelectionData,
        Info: int,
        Time: int,
    ):
        if Bash.file_exists(SelectionData.get_text()):
            Bash.run_async(f"wal -sten -i {SelectionData.get_text()}")
            Bash.run_async(f"swww img {SelectionData.get_text()}")

    def gen_item(label, onclick=lambda: (), **kwargs):
        return Widget.MenuItem(
            Widget.Label(label, hexpand=True, halign="start"),
            onactivate=onclick,
            **kwargs,
        )

    context_menu = Widget.Menu(
        [
            gen_item("Launch Terminal", lambda: Bash.run_async("blackbox -w $HOME")),
            gen_item(
                "Open Browser",
                lambda: Bash.run_async("xdg-open https://duckduckgo.com/"),
            ),
            gen_item(
                "File Manager",
                lambda: Bash.run_async("nautilus --new-window"),
            ),
            Gtk.SeparatorMenuItem.new(),
            gen_item(
                "Color Picker",
                lambda: Bash.run_async("colorpicker"),
            ),
            gen_item(
                "Screenshot",
                submenu=Widget.Menu(
                    [
                        gen_item(
                            "Window", lambda: Bash.run_async("screenshot --window")
                        ),
                        gen_item(
                            "Selection", lambda: Bash.run_async("screenshot --sel")
                        ),
                        gen_item("Screen", lambda: Bash.run_async("screenshot --all")),
                    ]
                ),
            ),
            gen_item(
                "Launch Apps",
                lambda: Bash.run_async("potatocli --exec ToggleLauncher"),
            ),
            Gtk.SeparatorMenuItem.new(),
            gen_item("Sex Mode"),
            Gtk.SeparatorMenuItem.new(),
            gen_item(
                "Power Menu",
                submenu=Widget.Menu(
                    [
                        gen_item("Shutdown", lambda: Bash.run_async("shutdown now")),
                        gen_item("Reboot", lambda: Bash.run_async("reboot")),
                        gen_item(
                            "Log Out", lambda: Bash.run_async("hyprctl dispatch exit")
                        ),
                        gen_item(
                            "Lock Session",
                            lambda: Bash.run_async("loginctl lock-session"),
                        ),
                    ]
                ),
            ),
        ],
        classname="desktop-menu",
    )

    tmp = Widget.EventBox(
        css="background: unset;",
        secondaryrelease=lambda event: context_menu.popup_at_pointer(event),
        hexpand=True,
        vexpand=True,
        children=Widget.Box([MediaWidget], halign="end", valign="start"),
    )

    tmp.drag_dest_set(Gtk.DestDefaults.ALL, [], Gdk.DragAction.COPY)
    tmp.drag_dest_add_text_targets()
    tmp.connect("drag-data-received", wrapper)

    return Widget.Window(
        position="top left right bottom",
        size=["100%", "100%"],
        layer="background",
        namespace="Wallpaper",
        children=Widget.Box(
            hexpand=True,
            vexpand=True,
            children=tmp,
        ),
    )


MyWall = Wall()
MyWall.open()
