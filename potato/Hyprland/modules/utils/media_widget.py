# quick solution bc i havent implemented a playerctl/mpris service

from typing import Union

from PotatoWidgets import Playerctl, Variable, Widget

manager = Playerctl.PlayerManager()

# https://lazka.github.io/pgi-docs/Playerctl-2.0/classes

# First add current players
for name in manager.props.player_names:
    manager.manage_player(
        Playerctl.Player.new_from_name(name),
    )

# manage connections
manager.connect("name-appeared", lambda *args: UpdatePlayers(*args, add=True))
manager.connect("name-vanished", lambda *args: UpdatePlayers(*args))


# now make a callback to handle appear/vanish players
def UpdatePlayers(
    _manager: Playerctl.PlayerManager, player: Playerctl.PlayerName, add: bool = False
):
    if add:
        new_player = Playerctl.Player.new_from_name(player)
        _manager.manage_player(new_player)

    # reload PlayersList var with new players as widgets
    PlayersList.set_value(
        list(
            map(
                lambda p: GenerateWidget(*ConnectPlayerToWidgets(p)),
                _manager.props.players,
            )
        )
    )


def GenerateWidget(
    Cover: Widget.Box,
    Title: Widget.Label,
    Artist: Widget.Label,
    Status: Widget.Icon,
    Source: str,
    Position: Union[Widget.ProgressBar, None] = None,
):

    Top = Widget.Box(
        spacing=10,
        children=[
            Widget.Icon(Source),
            Widget.Label(Source.title(), classname="media-source"),
        ],
    )
    Center = Widget.Box(
        [
            Widget.Box(
                vexpand=True,
                valign="center",
                orientation="v",
                children=[
                    Title,
                    Artist,
                    Position,
                ],
            ),
            Cover,
        ]
    )
    Bottom = Widget.Box(
        hexpand=True,
        halign="center",
        valign="end",
        spacing=30,
        children=[
            # Shuffle,
            Widget.Button(
                children=Widget.Icon(
                    "media-skip-backward-symbolic",
                    classname="black icon",
                )
            ),
            Status,
            Widget.Button(
                children=Widget.Icon(
                    "media-skip-forward-symbolic",
                    classname="black icon",
                )
            ),
            # Loop,
        ],
    )
    return Widget.Box(
        orientation="v",
        classname="media-widget player",
        hexpand=True,
        vexpand=True,
        children=[Top, Center, Bottom],
    )


def ConnectPlayerToWidgets(player: Playerctl.Player):
    metadata = dict(player.props.metadata)

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
        Playerctl.PlaybackStatus.PAUSED: "media-playback-pause-symbolic",
        Playerctl.PlaybackStatus.PLAYING: "media-playback-start-symbolic",
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
    # Source = Widget.Icon(player.props.player_name, 20)
    Source = player.props.player_name

    Cover = Widget.Box(
        css=f"""
            background-image: url("{metadata.get("mpris:artUrl")}");
            """,
        hexpand=True,
        valign="center",
        halign="end",
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
                dict(metadata)["xesam:title"].strip("[']"),
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
    return Cover, Title, Artist, Status, Source


def RescanPlayersToWidgets(players: list):
    # temp = []
    # for player in players:
    #    data = ConnectPlayerToWidgets(player)
    #    temp.append(GenerateWidget(*data))
    # return temp

    return map(lambda p: GenerateWidget(*ConnectPlayerToWidgets(p)), players)


PlayersList = Variable([])


MediaWidget = Widget.Box(
    classname="media-widget",
    orientation="v",
    valign="start",
    spacing=10,
    children=PlayersList,
)


PlayersList.value = RescanPlayersToWidgets(manager.props.players)
