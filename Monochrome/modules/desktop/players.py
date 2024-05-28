from PotatoWidgets import Playerctl, Variable, Widget
from PotatoWidgets.Imports import *

SourceReplace = {
    "firefox": ("firefox web browser", "firefox"),
    "edge": ("Microsoft edge dev", "microsoft-edge-dev"),
}


manager = Playerctl.PlayerManager()

# First add current players
for name in manager.get_property("player_names") or []:
    manager.manage_player(
        Playerctl.Player.new_from_name(name),
    )

# manage connections
manager.connect("name-appeared", lambda *args: UpdatePlayers(*args, add=True))
manager.connect("name-vanished", lambda *args: UpdatePlayers(*args))


# now make a callback to handle appear/vanish players
def UpdatePlayers(_manager, player, add: bool = False):
    if add:
        _manager.manage_player(Playerctl.Player.new_from_name(player))

    # reload PlayersList var with new players as widgets
    PlayersList.set_value(
        list(
            map(
                lambda p: GenerateWidget(*ConnectPlayerToWidgets(p)),
                _manager.get_property("players") or [],
            )
        )
    )


def GenerateWidget(
    Cover: Widget.Box,
    Title: Widget.Label,
    Artist: Widget.Label,
    Status: Widget.Icon,
    Source: str,
    Player: Playerctl.Player,
    Position: Union[Widget.ProgressBar, None] = None,
):
    TitleName, IconName = SourceReplace.get(Source, (Source, Source))

    if Source not in ["spotify"]:
        can_pause_play = Player.get_property("can_pause") and Player.get_property(
            "can_play"
        )
        can_go = Player.get_property("can_go_next") and Player.get_property(
            "can_go_previous"
        )
        can_seek = Player.get_property("can_seek")
    else:
        can_pause_play = True
        can_go = True
        can_seek = True

    Cover.add(
        Widget.Icon(
            IconName,
            16,
            classname="icon player-icon",
            halign="end",
            valign="end",
            hexpand=True,
        )
    )

    Buttons = Widget.Box(
        hexpand=True,
        halign="center",
        valign="end",
        spacing=30,
        children=[
            Widget.Button(
                onclick=lambda: Player.previous(),
                active=can_go or False,
                classname="media-button "
                + ("available" if can_go else "not-available"),
                children=Widget.Icon(
                    "media-skip-backward-symbolic",
                    classname="black icon",
                ),
            ),
            Widget.Button(
                onclick=lambda: Player.play_pause(),
                children=Status,
                active=can_pause_play or False,
                classname="media-button "
                + ("available" if can_pause_play else "not-available"),
            ),
            Widget.Button(
                onclick=lambda: Player.next(),
                active=can_go or False,
                classname="media-button "
                + ("available" if can_go else "not-available"),
                children=Widget.Icon(
                    "media-skip-forward-symbolic",
                    classname="black icon",
                ),
            ),
            # Loop,
        ],
    )
    Sections = Widget.Box(
        [
            Cover,
            Widget.Box(
                hexpand=True,
                vexpand=True,
                valign="center",
                orientation="v",
                children=[Title, Artist, Position, Buttons],
            ),
        ],
        spacing=10,
    )
    return Widget.Box(
        orientation="v",
        classname="player",
        attributes=lambda self: setattr(self, "player", Player),
        hexpand=True,
        vexpand=True,
        children=Sections,
    )


def ConnectPlayerToWidgets(player: Playerctl.Player):
    metadata = dict(player.get_property("metadata") or {})

    ShuffleIcons = {
        True: "media-playlist-shuffle-symbolic",
        False: "media-playlist-consecutive-symbolic",
    }

    LoopIcons = {
        Playerctl.LoopStatus.NONE: "media-playlist-repeat-symbolic",
        Playerctl.LoopStatus.PLAYLIST: "media-playlist-repeat-symbolic",
        Playerctl.LoopStatus.TRACK: "media-playlist-repeat-song-symbolic",
    }
    StatusIcons = {
        Playerctl.PlaybackStatus.PAUSED: "media-playback-start-symbolic",
        Playerctl.PlaybackStatus.PLAYING: "media-playback-pause-symbolic",
        Playerctl.PlaybackStatus.STOPPED: "media-playback-stop-symbolic",
    }
    Title = Widget.Label(
        metadata.get("xesam:title", "['']").strip("[']"),
        classname="media-title",
        maxchars=30,
        justify="left",
        xalign=0,
        halign="start",
    )

    Artist = Widget.Label(
        str(
            metadata.get("xesam:artist")
            or metadata.get("xesam:album")
            or metadata.get("xesam:albumArtist")
        ).strip("[']"),
        classname="media-artist",
        justify="left",
        xalign=0,
        halign="start",
    )

    Shuffle = Widget.Icon(
        "media-playlist-consecutive-symbolic",
        size=24,
        classname="black icon media-shuffle",
    )

    Loop = Widget.Icon(
        "media-playlist-repeat-symbolic", size=24, classname="black icon media-loop"
    )
    Position = Widget.Scale(min=0, value=50, max=100)

    Status = Widget.Icon(
        "media-playback-pause-symbolic", size=24, classname="black icon media-status"
    )
    Source = player.get_property("player_name")

    Cover = Widget.Box(
        css=f"""
            background-image: url("{metadata.get("mpris:artUrl")}");
            """,
        valign="center",
        halign="start",
        classname="media-cover",
    )

    #
    #
    #
    #
    #
    player.connect(
        "playback-status",
        lambda _, s: Status.set_icon(
            StatusIcons.get(s, "media-playback-pause-symbolic")
        ),
    )
    player.connect(
        "loop-status",
        lambda _, s: Shuffle.set_icon(
            ShuffleIcons.get(s, "media-playlist-shuffle-symbolic")
        ),
    )
    player.connect(
        "shuffle",
        lambda _, s: Shuffle.set_icon(
            ShuffleIcons.get(s, "media-playlist-shuffle-symbolic")
        ),
    )
    player.connect(
        "metadata",
        lambda _, metadata: (
            Title.set_text(
                dict(metadata).get("xesam:title", "").strip("[']"),
            ),
            Artist.set_text(
                next(
                    (
                        str(dict(metadata).get(key, ""))
                        for key in [
                            "xesam:artist",
                            "xesam:album",
                            "xesam:albumArtist",
                        ]
                        if dict(metadata).get(key)
                    ),
                    "['']",
                ).strip("[']")
            ),
            # Artist.set_text(),
            Cover.set_css(
                f"""background-image: url("{dict(metadata).get("mpris:artUrl")}");"""
            ),
        ),
    )
    # return Cover, Title, Artist, Status, Position
    return Cover, Title, Artist, Status, Source, player


def RescanPlayersToWidgets(players: list):
    temp = []
    for player in players:
        data = ConnectPlayerToWidgets(player)
        temp.append(GenerateWidget(*data))
    return temp


PlayersList = Variable([])


MediaWidget = Widget.Box(
    classname="media-widget",
    orientation="v",
    valign="start",
    spacing=10,
    children=PlayersList,
)

PlayersList.value = RescanPlayersToWidgets(manager.get_property("players"))
