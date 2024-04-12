from PotatoWidgets import Widget

# proceso = Bash.popen("pactl subcribe", stdout=print)


Desktop = Widget.Window(
    size=["100%", "100%"],
    layer="background",
    namespace="Wallpaper",
    position="center",
    children=Widget.Box(
        classname="wallpaper",
        hexpand=True,
        vexpand=True,
        children=Widget.Box(
            classname="children",
            hexpand=True,
            vexpand=True,
            orientation="v",
        ),
    ),
)
