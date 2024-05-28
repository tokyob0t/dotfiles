from time import sleep as time_sleep

from PotatoWidgets import DIR_CONFIG_POTATO, Bash, Variable, Widget, make_async
from PotatoWidgets.Services import BatteryService
from PotatoWidgets.Services.Hyprland import HyprlandService

from .hypr import ActiveWindow, ActiveWorkspaces, Window, Workspace
from .network import NETWORK_ICON, network_info

# from PotatoWidgets.Services.Hyprland import HyprlandService

SymbolicFiles = Bash.get_output(
    f"""ls -1 {DIR_CONFIG_POTATO}/Magenta/resources/symbolic/ | sed 's/\\.[^.]*$//' """,
    list,
)


def get_symbolic(
    name,
    size=32,
    halign="center",
    valign="center",
    vexpand=True,
    hexpand=True,
):

    if name in SymbolicFiles:
        return Widget.Image(
            _get_filepath(name),
            size,
            halign=halign,
            valign=valign,
            vexpand=vexpand,
            hexpand=hexpand,
        )
    return Widget.Icon(
        name, size, halign=halign, valign=valign, vexpand=vexpand, hexpand=hexpand
    )


def _get_filepath(name: str):
    return f"{DIR_CONFIG_POTATO}/Magenta/resources/symbolic/{name}.svg"


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

        mute = Bash.get_output(
            """ [[ $(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}') == "yes" ]] && echo true || echo false  """,
            bool,
        )

        volume: int = Bash.get_output(
            "pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3 }(?=%)' | head -1",
            int,
        )

        return mute, volume

    mute, vol = get_value()

    return {"icon": icon(mute, vol), "value": vol}


def get_brightness():

    def get_value():
        output: int = Bash.get_output("brightnessctl get", int)
        return round((output / MAX_BRIGHTNESS) * 100)

    return {"icon": "display-brightness-symbolic", "value": get_value()}


sended_notif_battery = False


def __send_notif(level: int):
    if BatteryService.state == 1 or level not in [40, 30, 20, 10]:
        return

    messages = {
        40: "Battery is at 40%, consider plugging in the charger soon :D",
        30: "Battery is at 30%, it would be a good idea to plug in the charger soon :)",
        20: "Battery is at 20%, plug in the charger before it runs out :/",
        10: "Battery is at 10%, plug in the charger now or it will shutdown soon... >:(",
    }

    message = messages.get(level, f"Plug the fakin charger, **{level}%** left D:< ")
    Bash.run_async(
        f"notify-send -a batterylevel -i {BatteryService.icon_name} 'Battery Notification' '{message}'"
    )


BatteryService.connect("percentage", lambda _, val: __send_notif(round(val)))


def BATTERY_ICON() -> Widget.Icon:
    return Widget.Icon(BatteryService.bind("icon-name"), 20, classname="icon")


def BRIGHTNESS_ICON(size: int = 20) -> Widget.Image:
    def wrapper(value: int):
        value = (value // 10) * 10

        if 10 <= value <= 90:
            return _get_filepath(f"md-lightbulb_on_{value}")
        elif value >= 100:
            return _get_filepath("md-lightbulb_on")
        else:
            return _get_filepath("md-lightbulb_on_outline")

    return Widget.Image(
        _get_filepath("md-lightbulb_on"),
        size,
        classname="icon",
        attributes=lambda self: self.bind(
            BrightnessInfo,
            lambda out: self.set_image(wrapper(out["value"])),
        ),
    )


def VOLUME_ICON(size: int = 20) -> Widget.Icon:
    return Widget.Icon(
        "audio-volume-medium-symbolic",
        size,
        classname="icon",
        attributes=lambda self: self.bind(
            VolumeInfo,
            lambda out: self.set_icon(out["icon"]),
        ),
    )


def WorkspacesWidget() -> Widget.Box:
    def wrapper(w_list: list[Workspace]):
        for i in tmp_box.get_children():
            wp_data: Workspace = next(j for j in w_list if j.id == getattr(i, "id"))
            label: Widget.Label = i.get_children()[0]

            match wp_data.is_active:
                case 2:
                    label.set_text("")
                case 1:
                    label.set_text("")
                case 0:
                    label.set_text("")

    tmp_box = Widget.Box(
        list(
            map(
                lambda id: Widget.Button(
                    Widget.Label(
                        text="",
                        classname="nf-icon",
                    ),
                    attributes=lambda self: setattr(self, "id", id),
                    onclick=lambda: HyprlandService.hyprctl(f"dispatch workspace {id}"),
                ),
                range(1, 8),
            )
        ),
        orientation="v",
        spacing=5,
        vexpand=True,
        valign="center",
    )
    ActiveWorkspaces.bind(wrapper)
    return tmp_box


FILE = Bash.get_output("ls -1 /sys/class/backlight/", list)
FILE = FILE[0]
FILE = f"/sys/class/backlight/{FILE}/brightness"

MAX_BRIGHTNESS = Bash.get_output("brightnessctl max", int)


Bash.monitor_file(
    FILE,
    flags="watch_moves",
    call_when=["changed"],
    callback=lambda: UpdateBrightness(),
)

VOLUME_MONITOR = Bash.popen(
    """bash -c 'pactl subscribe | grep --line-buffered "on sink"' """,
    stdout=lambda _: UpdateVolume(),
)


def UpdateVolume():
    new_vol = get_volume()
    if new_vol != VolumeInfo.value:
        VolumeInfo.value = new_vol


def UpdateBrightness():
    new_br = get_brightness()
    if new_br != BrightnessInfo.value:
        BrightnessInfo.value = new_br


# Variables
BrightnessInfo = Variable(get_brightness())
VolumeInfo = Variable(get_volume())
