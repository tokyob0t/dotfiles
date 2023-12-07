import json
from subprocess import run

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from html.parser import HTMLParser


def getIcon(icon_name):
    if icon_name is not None:
        theme = Gtk.IconTheme.get_default()

        for name in [icon_name.lower(), icon_name.title(), icon_name.capitalize(), icon_name]:
            icon_info = theme.lookup_icon(name, 128, 0)
            if icon_info is not None:
                return icon_info.get_filename()

    return None
    

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



def update(var, val):
    run(["eww", "update", f"{var}={json.dumps(val)}"])
