from PotatoWidgets import Variable, Widget, wait

from ..common import BRIGHTNESS_ICON, VOLUME_ICON, BrightnessInfo, VolumeInfo


def gen_popup(Icon: Widget.Icon | Widget.Image, Bindable: Variable) -> Widget.Window:
    def DecreaseCount(self: Widget.Window):
        setattr(self, "count", getattr(self, "count") - 1)

        if getattr(self, "count") == 1:
            wait("3s", tmp_progress.set_classname, "osd-scale")
            wait("3s", tmp_progress.set_classname, "icon")
        elif getattr(self, "count") == 0:
            return self.close()

    def IncreaseCount(self: Widget.Window):
        for popup in [VolumePopup, BrightnessPopup]:
            if popup != self:
                popup.close()

        setattr(self, "count", getattr(self, "count") + 1)

        wait("3s", DecreaseCount, self)

        if getattr(self, "count") == 1:
            tmp_progress.set_classname("osd-scale")
            if isinstance(Icon, Widget.Icon):
                Icon.set_classname("icon")
            elif isinstance(Icon, Widget.Image):
                Icon.set_opacity(1)
            wait("5s", tmp_progress.set_classname, "osd-scale smol")
            if isinstance(Icon, Widget.Icon):
                wait("5s", Icon.set_classname, "icon transparent")
            elif isinstance(Icon, Widget.Image):
                wait("5s", Icon.set_opacity, 0)
        else:

            value = tmp_progress.get_fraction() * 100
            is_smol = "smol" in tmp_progress.get_classname()
            pulse_class = (
                "pulse-high" if value < Bindable.value["value"] else "pulse-less"
            )

            base_classname = "osd-scale " + pulse_class
            final_classname = base_classname + " smol" if is_smol else base_classname

            tmp_progress.set_classname(final_classname)
            if is_smol:
                wait(50, tmp_progress.set_classname, "osd-scale smol")
            else:
                wait(50, tmp_progress.set_classname, "osd-scale")
            return self.open()

    tmp_label = Widget.Label(
        halign="center",
        text=Bindable.value["value"],
    )
    tmp_progress = Widget.ProgressBar(
        classname="osd-scale",
        valign="center",
        halign="center",
        orientation="v",
        inverted=True,
        hexpand=True,
        vexpand=True,
        value=Bindable.value["value"],
    )
    Icon.set_valign("end")

    tmp_window = Widget.Window(
        at={"right": 20},
        position="right",
        layer="overlay",
        attributes=lambda self: setattr(self, "count", 0),
        children=Widget.Overlay([tmp_progress, Icon], classname="osd-box"),
    )

    Bindable.bind(
        lambda out: (
            IncreaseCount(tmp_window),
            tmp_label.set_text(out["value"]),
            tmp_progress.set_value(out["value"]),
        )
    )

    return tmp_window


VolumePopup = gen_popup(VOLUME_ICON(), VolumeInfo)
BrightnessPopup = gen_popup(BRIGHTNESS_ICON(), BrightnessInfo)
