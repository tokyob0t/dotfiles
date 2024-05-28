from PotatoWidgets import Widget


def Overview(monitor=0):
    tmp = Widget.Window(
        size=["20%", "20%"],
        at={"left": 20, "top": 50},
        position="top left right",
        namespace=f"Overview_{monitor}",
        monitor=monitor,
        children=Widget.Box(Widget.Label("A"), css="background: #161616;"),
    )
    return tmp


OverviewWindow = Overview()
