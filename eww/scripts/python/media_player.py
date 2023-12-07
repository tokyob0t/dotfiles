#!/usr/bin/env python3

import json
import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import Playerctl, GLib

def update_eww(player):
    if player:
        metadata = player.get_metadata()
        shuffle = player.get_property('shuffle')
        loop = player.get_property('loop')
        status = player.get_property('status')
        length = metadata.get('mpris:length', '')
        artist = metadata.get('xesam:artist', [''])[0]
        title = metadata.get('xesam:title', '')
        art_url = metadata.get('mpris:artUrl', '')

        line = {
            "source": player.get_name(),
            "shuffle": shuffle,
            "loop": loop,
            "status": status,
            "length": length,
            "artist": artist,
            "title": title,
            "artUrl": art_url
        }
    else:
        line = {
            "source": "",
            "shuffle": "",
            "loop": "",
            "status": "",
            "length": "",
            "artist": "",
            "title": "",
            "artUrl": ""
        }

    print(json.dumps(line))

def on_metadata(player, metadata):
    update_eww(player)

def on_play(player, status):
    update_eww(player)

def on_pause(player, status):
    update_eww(player)

player = Playerctl.Player()

player.connect('playback-status::playing', on_play)
player.connect('playback-status::paused', on_pause)
player.connect('metadata', on_metadata)



# Esperar por eventos
main = GLib.MainLoop()
main.run()
