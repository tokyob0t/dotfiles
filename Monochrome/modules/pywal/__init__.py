from PotatoWidgets import DIR_CONFIG_POTATO, DIR_HOME, Bash
from PotatoWidgets.Services.Style import Style

PywalFile = f"{DIR_CONFIG_POTATO }/Magenta/scss/colors.scss"

Bash.monitor_file(
    PywalFile,
    flags="watch_moves",
    callback=lambda: Style.load_css(f"{DIR_CONFIG_POTATO}/Magenta/style.scss"),
    call_when=["changed"],
)
