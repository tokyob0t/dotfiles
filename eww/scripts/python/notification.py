#!/usr/bin/env python3
# juminai @ github

from inspect import getinnerframes
import gi
import datetime
import os
import subprocess
import json
import dbus
import dbus.service
from _common import getIcon, stringEscape

gi.require_version("GdkPixbuf", "2.0")
gi.require_version("Gtk", "3.0")

from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib, Gtk, GdkPixbuf


class NotificationDaemon(dbus.service.Object):
    def __init__(self):
        bus_name = dbus.service.BusName("org.freedesktop.Notifications", dbus.SessionBus())
        dbus.service.Object.__init__(self, bus_name, "/org/freedesktop/Notifications")
        self.log_file = os.path.expandvars("/home/tokyob0t/.cache/eww/notifications.json")
        self.cache_dir = os.path.expandvars("/home/tokyob0t/.cache/eww/notifications_img")
        os.makedirs(self.cache_dir, exist_ok=True)


        self.active_popups = {}
        self.notifications_list = self.load()
        self.dnd = self.notifications_list["dnd"]
        self.update_eww(False)

    @dbus.service.method("org.freedesktop.Notifications", in_signature="susssasa{sv}i", out_signature="u")
    def Notify(self, app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout,):
        subprocess.run("eww open notifpopup --duration 5000 > /dev/null 2>&1 & ", shell=True)

        if replaces_id != 0:
            id = replaces_id
        else:
            if self.notifications_list.get("notifications", []):
                id = self.notifications_list.get("notifications", [])[0]["id"] + 1
            else:
                id = 1

        actions = list(actions)
        pairs = []

        for i in range(0, len(actions), 2):
            if actions[i + 1] != "":
                pairs.append({
                    "label": actions[i + 1],
                    "id": actions[i]
                })
            
        if app_icon.strip():
            if os.path.isfile(app_icon) or app_icon.startswith("file://"):
                icon = app_icon
            else:
                icon = getIcon(app_icon)
        else:
            icon = None

        if "image-data" in hints:
            image_data = hints["image-data"]
            image_path = f"{self.cache_dir}/{id}.png"
            self.save_img_byte(image_data, image_path)
            icon = image_path
        
        if app_name.lower() == "screenshot":
            glyph = getIcon("camera")
        elif app_name.lower() in  ["vencorddesktop", "betterdiscord"] :
            glyph = getIcon("discord")
        elif app_name.lower() == "color picker":
            glyph = getIcon("colorgrab")
        else:
            glyph = getIcon(app_name) or getIcon("user-available-symbolic")
            
        details = {
            "id": id,
            "app": app_name.capitalize() or "NULL",
            "glyph": glyph,
            "image": icon or "NULL",
            "summary": stringEscape(summary) or "NULL",
            "body": stringEscape(body) or "NULL",
            "time": datetime.datetime.now().strftime("%H:%M:%S"),
            "actions": pairs,
        }

        self.save_notification(details)
        if not self.dnd:
            self.save_popup(details)
        return id


    @dbus.service.method("org.freedesktop.Notifications", in_signature="", out_signature="ssss")
    def GetServerInformation(self):
        return ("dbus notifications", "klyn", "1.0", "1.2")


    @dbus.service.method("org.freedesktop.Notifications", in_signature="", out_signature="as")
    def GetCapabilities(self):
        return ("actions", "body", "icon-static", "persistence")


    @dbus.service.signal("org.freedesktop.Notifications", signature="us")
    def ActionInvoked(self, id, action):
        return (id, action)


    @dbus.service.method("org.freedesktop.Notifications", in_signature="us", out_signature="")
    def InvokeAction(self, id, action):
        self.ActionInvoked(id, action)


    @dbus.service.signal("org.freedesktop.Notifications", signature="uu")
    def NotificationClosed(self, id, reason):
        return (id, reason)
 
   
    @dbus.service.method("org.freedesktop.Notifications", in_signature="", out_signature="")
    def ToggleDND(self):
        self.dnd = not self.dnd
        self.notifications_list["dnd"] = self.dnd
        self.update_eww()


    @dbus.service.method("org.freedesktop.Notifications", in_signature="u", out_signature="")
    def CloseNotification(self, id):
        for notification in self.notifications_list["notifications"]:
            if notification["id"] == id:
                self.notifications_list["notifications"].remove(notification)
                break
                
        self.notifications_list["count"] = len(self.notifications_list["notifications"])
        self.NotificationClosed(id, 2)
        self.DismissPopup(id)
        self.update_eww()


    @dbus.service.method("org.freedesktop.Notifications", in_signature="u", out_signature="")
    def DismissPopup(self, id):
        for notification in self.notifications_list["popups"]:
            if notification["id"] == id:
                self.notifications_list["popups"].remove(notification)
                break

        self.active_popups.pop(id, None)
        self.update_eww()


    @dbus.service.method("org.freedesktop.Notifications", in_signature="", out_signature="")
    def ClearAll(self):
        for notification in self.notifications_list["notifications"]:
            self.NotificationClosed(notification["id"], 2)
            
        self.notifications_list["count"] = 0
        self.notifications_list["notifications"] = []
        self.notifications_list["popups"] = []
        self.update_eww()
        
        for popup_id in self.active_popups.keys():
            GLib.source_remove(self.active_popups[popup_id])
        self.active_popups = {}


    def save_img_byte(self, px_args, save_path: str):
        GdkPixbuf.Pixbuf.new_from_bytes(
            width=px_args[0],
            height=px_args[1],
            has_alpha=px_args[3],
            data=GLib.Bytes(px_args[6]),
            colorspace=GdkPixbuf.Colorspace.RGB,
            rowstride=px_args[2],
            bits_per_sample=px_args[4],
        ).savev(save_path, "png")

    def save_notification(self, notification):
        for existing_notification in self.notifications_list["notifications"]:
            if existing_notification["id"] == notification["id"]:
                self.notifications_list["notifications"].remove(existing_notification)
                break

        self.notifications_list["notifications"].insert(0, notification)
        self.notifications_list["count"] = len(self.notifications_list["notifications"])
        self.update_eww()


    def save_popup(self, notification):
        for existing_notification in self.notifications_list["popups"]:
            if existing_notification["id"] == notification["id"]:
                self.notifications_list["popups"].remove(existing_notification)
                GLib.source_remove(self.active_popups[existing_notification["id"]])
                break

        if len(self.notifications_list["popups"]) >= 3:
            oldest_popup = self.notifications_list["popups"].pop(-1)
            self.DismissPopup(oldest_popup["id"])
    
        self.notifications_list["popups"].insert(0, notification)
        self.update_eww()
        
        popup_id = notification["id"]
        self.active_popups[popup_id] = GLib.timeout_add_seconds(6, self.DismissPopup, popup_id)


    def load(self):
        try:
            with open(self.log_file, "r") as log:
                return json.load(log)
        except (FileNotFoundError, json.JSONDecodeError):
            return {
                "count": 0, 
                "dnd": False, 
                "notifications": [], 
                "popups": []
            }
    
    def update_eww(self, w=True):
        if w:
            with open(self.log_file, "w") as log:
                json.dump(self.notifications_list, log, indent=2)

        subprocess.run([
            "eww", "update", f"notifications={json.dumps(self.notifications_list)}"
        ])


if __name__ == "__main__":
    DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    NotificationDaemon()
    try:
        loop.run()
    except KeyboardInterrupt:
        exit(0)