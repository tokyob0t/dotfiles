from PotatoWidgets import Widget, lookup_icon

from ...utils.weather import WEATHER


def gen_weather_widget(data):
    return Widget.Box(
        vexpand=True,
        hexpand=True,
        halign="center",
        valign="center",
        orientation="v",
        spacing=10,
        # css=f"""background-color: {data["hex"]};""",
        children=[
            Widget.Box(
                halign="center",
                spacing=5,
                children=[
                    Widget.Label("󰋜", classname="nf-icon"),
                    Widget.Label(
                        data["city"],
                        classname="weather-city weather-label",
                    ),
                ],
            ),
            Widget.Box(
                spacing=20,
                children=[
                    Widget.Icon(
                        data["icon"],
                        size=70,
                        classname="icon black",
                        halign="start",
                        valign="center",
                        vexpand=True,
                    ),
                    Widget.Box(
                        valign="start",
                        children=[
                            Widget.Label(
                                data["temperature"],
                                css="font-size: 50px;",
                                classname="weather-label",
                                valign="start",
                                yalign=0,
                            ),
                            Widget.Label(
                                "°C",
                                classname="weather-label",
                                valign="center",
                                yalign=0,
                                css="font-size: 35px;",
                            ),
                        ],
                    ),
                    Widget.Box(
                        orientation="v",
                        children=[
                            Widget.Label(
                                data["description"],
                                classname="weather-label",
                            ),
                            Widget.Box(
                                halign="end",
                                children=[
                                    Widget.Label(
                                        "",
                                        classname="nf-icon",
                                        css="font-size: 14px;",
                                    ),
                                    Widget.Label(
                                        data["humidity"] + "%",
                                        classname="weather-label",
                                    ),
                                    # Widget.Box(size=[10, 0]),
                                    # Widget.Label(
                                    #    "",
                                    #    classname="nf-icon",
                                    #    css="font-size: 14px;",
                                    # ),
                                    # Widget.Label(
                                    #    data["pressure"], classname="weather-label"
                                    # ),
                                ],
                            ),
                        ],
                    ),
                ],
            ),
        ],
    )


WeatherWidget = Widget.Box(
    halign="center",
    attributes=lambda self: (
        self.bind(
            WEATHER,
            lambda out: self.set_children(
                gen_weather_widget(out),
            ),
        ),
        setattr(self, "WEATHER", WEATHER.value),
    ),
    children=gen_weather_widget(
        WEATHER.value,
    ),
)
