from PotatoWidgets import PotatoLoop
from PotatoWidgets.Imports import Gio, GLib, gi

gi.require_version("Soup", "3.0")
from gi.repository import Soup

# https://lazka.github.io/pgi-docs/Gio-2.0/classes/AsyncResult.html#Gio.AsyncResult


def hacer_solicitud(url):
    session = Soup.Session.new()
    request = Soup.Message.new("GET", url)

    def imprimir_respuesta(session, result):
        if result.propagate_boolean():
            response = session.send_finish(result)
            print(response)
            # body = response.get_soup().get_text()
            # print(body)

    session.send_async(request, GLib.PRIORITY_LOW, None, imprimir_respuesta)
