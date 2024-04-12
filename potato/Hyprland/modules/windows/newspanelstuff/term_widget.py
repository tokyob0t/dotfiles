from typing import Callable, List, Literal, Union

from PotatoWidgets import DIR_CONFIG, DIR_HOME, Gdk, GLib, Pango, Widget
from PotatoWidgets.Imports import gi
from PotatoWidgets.Widget.Box import BasicProps

gi.require_version("Vte", "2.91")

from gi.repository import Vte


def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")
    r_hex = hex_color[0:2]
    g_hex = hex_color[2:4]
    b_hex = hex_color[4:6]

    r_decimal = hex_to_decimal(r_hex)
    g_decimal = hex_to_decimal(g_hex)
    b_decimal = hex_to_decimal(b_hex)

    if len(hex_color) > 6:
        a_hex = hex_color[6:8]
        a_decimal = hex_to_decimal(a_hex)
    else:
        a_decimal = 1
    return (r_decimal, g_decimal, b_decimal, a_decimal)


def hex_to_decimal(hex_value):
    decimal_value = int(hex_value, 16)
    normalized_value = decimal_value / 255.0
    return normalized_value


def gen_rgba(color="#ffffff"):
    col = Gdk.RGBA()

    col.red, col.blue, col.green, col.alpha = hex_to_rgb(color)
    return col


Colors = [
    gen_rgba(i)
    for i in [
        "#262626",
        "#ff7eb6",
        "#42be65",
        "#82cfff",
        "#33b1ff",
        "#ee5396",
        "#3ddbd9",
        "#dde1e6",
        "#393939",
        "#ff7eb6",
        "#42be65",
        "#82cfff",
        "#33b1ff",
        "#ee5396",
        "#3ddbd9",
        "#ffffff",
    ]
]


class Terminal(Vte.Terminal, BasicProps):
    def __init__(
        self,
        halign: Literal["fill", "start", "center", "end", "baseline"] = "fill",
        valign: Literal["fill", "start", "center", "end", "baseline"] = "fill",
        hexpand: bool = False,
        vexpand: bool = False,
        classname: str = "",
        css: str = "",
        visible: Union[bool, None] = None,
        active: Union[bool, None] = None,
        size: Union[int, str, List[Union[int, str]], List[int]] = 0,
        attributes: Callable = lambda self: self,
    ) -> None:
        Vte.Terminal.__init__(self)
        Vte.Terminal.set_size(self, 75, 15)

        BasicProps.__init__(
            self,
            halign,
            valign,
            hexpand,
            vexpand,
            classname,
            css,
            visible,
            active,
            size,
            attributes,
        )


Term = Terminal(classname="terminal")
Term.spawn_sync(
    Vte.PtyFlags.DEFAULT,
    DIR_HOME,
    ["/bin/zsh"],
    None,
    GLib.SpawnFlags.DO_NOT_REAP_CHILD,
    None,
    None,
)
Term.set_font(Pango.FontDescription.from_string("JetBrainsMono Nerd Font"))
Term.set_colors(
    foreground=gen_rgba("#161616"),
    background=gen_rgba("#161616"),
    palette=Colors,
)

Term.set_clear_background(False)

TermWidget = Widget.Box(orientation="v", children=Term)
