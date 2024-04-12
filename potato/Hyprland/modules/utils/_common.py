import json
import os
import subprocess
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from subprocess import PIPE
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop

import gi

gi.require_version("GdkPixbuf", "2.0")
gi.require_version("Gtk", "3.0")
from gi.repository import GdkPixbuf, GLib, Gtk


def shellRun(args, shell=False):
    return subprocess.run(args, shell=shell)


def shellOut(args):
    try:
        return json.loads(subprocess.getoutput(args))
    except:
        return subprocess.getoutput(args)


def shellCheckOut(args):
    return subprocess.check_output(args).decode().strip()


def shellPopen(args):
    return subprocess.Popen(args, stdout=PIPE, text=True)


def getIcon(icon_name, size=128, path=True):
    if icon_name is not None:
        theme = Gtk.IconTheme.get_default()

        for name in [
            icon_name.lower(),
            icon_name.title(),
            icon_name.capitalize(),
            icon_name,
        ]:
            icon_info = theme.lookup_icon(
                name,
                size,
                Gtk.IconLookupFlags.USE_BUILTIN,
            )
            if icon_info is not None:
                return icon_info.get_filename() if path else icon_info
    return None


def getSVG(svg_filename):
    temp_path = "/home/tokyob0t/.cache/eww/icon"
    os.makedirs(temp_path, exist_ok=True)

    modified_filename = os.path.join(temp_path, os.path.basename(svg_filename))

    if os.path.exists(modified_filename):
        return modified_filename
    else:
        modified_content = editColors(svg_filename)
        with open(modified_filename, "w") as file:
            file.write(modified_content)

        return modified_filename


def editColors(svg_filename):
    with open(svg_filename, "r") as file:
        svg_content = file.read()

    root = ET.fromstring(svg_content)

    for elem in root.iter():
        for key, value in elem.attrib.items():
            if "fill" in key:
                if value in ["#2e3434", "#2e3436"]:
                    elem.attrib[key] = "#dde1e6"
                elif value == "#ed333b":
                    elem.attrib[key] = "#ee5396"
                elif value == "#33d17a":
                    elem.attrib[key] = "#42BE65"

        style_attr = elem.attrib.get("style", "")
        style_values = [style.strip() for style in style_attr.split(";")]

        for i, style_value in enumerate(style_values):
            if style_value.startswith("fill:"):
                color_value = style_value.split(":")[1].strip()
                if color_value in [
                    "#2e3434",
                    "#2e3436",
                    "rgb(13.333334%,13.333334%,13.333334%)",
                ]:
                    style_values[i] = "fill: #dde1e6"
                elif color_value == "#ed333b":
                    style_values[i] = "fill: #ee5396"
                elif color_value == "#33d17a":
                    style_values[i] = "fill: #42BE65"

        elem.attrib["style"] = ";".join(style_values)

    return ET.tostring(root, encoding="unicode")


def stringEscape(text):
    class HTMLTagStripper(HTMLParser):
        def __init__(self):
            super().__init__()
            self.reset()
            self.strict = False
            self.convert_charrefs = True
            self.text = []

        def handle_data(self, data):
            self.text.append(data)

        def get_text(self):
            return "".join(self.text)

    stripper = HTMLTagStripper()
    stripper.feed(text)
    text = stripper.get_text()
    return text.strip()
