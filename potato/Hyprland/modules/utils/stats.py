from re import search as re_search
from typing import Match, Union

from PotatoWidgets import Bash, BatteryService, Gio, Variable, Widget, wait


def get_volume():

    def icon(muted: bool, value: int) -> str:
        if value == 0 or muted:
            return "audio-volume-muted-symbolic"
        elif value < 30:
            return "audio-volume-low-symbolic"
        elif value < 65:
            return "audio-volume-medium-symbolic"
        else:
            return "audio-volume-high-symbolic"

    def get_value():

        mute_output: str = Bash.get_output("pactl get-sink-mute @DEFAULT_SINK@")
        mute: bool = {"no": False, "yes": True}.get(
            mute_output.lstrip("Mute: ").replace("\n", ""), False
        )

        volume_output: str = Bash.get_output("pactl get-sink-volume @DEFAULT_SINK@")
        volume_match: Union[Match[str], None] = re_search(r"(\d+)%", volume_output)

        if volume_match:
            volume = int(volume_match.group(1))
        else:
            volume = 0

        return mute, volume

    vol = get_value()

    return {"icon": icon(*vol), "value": vol[1]}


def get_brightness():

    def get_value():
        output: str = Bash.get_output("brightnessctl")
        match: Union[Match[str], None] = re_search(r"Current.*\((\d{1,3})%\)", output)

        if match is not None:
            return int(match.group(1))
        else:
            return 0

    return {"icon": "display-brightness-symbolic", "value": get_value()}


def on_brightness_changed(
    # Parameters described on https://lazka.github.io/pgi-docs/Gio-2.0/classes/FileMonitor.html#Gio.FileMonitor.signals.changed
    FileMonitor: Gio.FileMonitor,
    LocalFile: Gio.File,
    _: Union[Gio.File, None],
    Event: Gio.FileMonitorEvent,
):
    # Event Type, check https://lazka.github.io/pgi-docs/Gio-2.0/enums.html#Gio.FileMonitorEvent
    if Event == Gio.FileMonitorEvent.CHANGED:
        BRIGHTNESS_INFO.value = get_brightness()


def BRIGHTNESS_ICON(size=16, css="") -> Widget.Icon:
    return Widget.Icon(
        "display-brightness-symbolic",
        size,
        css=css,
        classname="icon black",
        attributes=lambda self: self.bind(
            BRIGHTNESS_INFO,
            lambda out: self.set_icon(out["icon"]),
        ),
    )


def VOLUME_ICON() -> Widget.Icon:
    return Widget.Icon(
        "audio-volume-medium-symbolic",
        16,
        classname="icon",
        attributes=lambda self: self.bind(
            VOLUME_INFO,
            lambda out: self.set_icon(out["icon"]),
        ),
    )


def BATTERY_ICON() -> Widget.Icon:
    batservice = BatteryService()
    return Widget.Icon(
        "battery-level-100-symbolic",
        16,
        classname="icon",
        attributes=lambda self: (
            batservice.connect(
                "percentage",
                lambda instance, percentage: self.set_icon(
                    "battery-level-{}{}-symbolic".format(
                        (round(percentage // 10) * 10),
                        ("-charging" if instance.state == 1 else ""),
                    )
                ),
            ),
            batservice.connect(
                "state",
                lambda instance, state: self.set_icon(
                    "battery-level-{}{}-symbolic".format(
                        (round(instance.percentage // 10) * 10),
                        ("-charging" if state == 1 else ""),
                    )
                ),
            ),
        ),
    )


_FILE = Bash.get_output("ls -1 /sys/class/backlight/").splitlines()[0]
BRIGHTNESS_MONITOR = Bash.monitor_file(f"/sys/class/backlight/{_FILE}/brightness")
BRIGHTNESS_MONITOR.connect(
    "changed",
    lambda *args: (
        on_brightness_changed(*args),
        OsdRevealer.set_value(1),
    ),
)

VOLUME_MONITOR = Bash.popen(
    """bash -c 'pactl subscribe | grep --line-buffered "on sink"' """,
    stdout=lambda _: (
        (
            VOLUME_INFO.set_value(get_volume())
            if VOLUME_INFO.value != get_volume()
            else None
        ),
        OsdRevealer.set_value(2),
    ),
)


# Variables
BRIGHTNESS_INFO = Variable(get_brightness())
VOLUME_INFO = Variable(get_volume())


OsdRevealer = Variable(-1)
# OsdRevealer.bind(lambda _: wait("5s", OsdRevealer.set_value, -1))
