import subprocess
import time


def gsettings(*arguments: str) -> None:
    subprocess.run(
        ["gsettings", *arguments],
        check=False,
    )


def luminance(color: str) -> float:
    channels = [int(color[index : index + 2], 16) / 255 for index in (0, 2, 4)]
    linear = [
        value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4
        for value in channels
    ]
    return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]


schema = "org.gnome.desktop.interface"
background = luminance("{{ colors.base00 }}")
foreground = luminance("{{ colors.base05 }}")
dark = background < foreground
color_scheme = "prefer-dark" if dark else "prefer-light"
gsettings("set", schema, "color-scheme", color_scheme)

target_theme = "Adwaita-dark" if dark else "Adwaita"

# Changing the setting forces running GTK 3 applications to reconstruct their
# theme provider after stash has replaced gtk.css. Using the matching base
# variant also keeps widgets not covered by our overrides consistently dark or
# light.
temporary_theme = "Adwaita" if dark else "Adwaita-dark"
gsettings("set", schema, "gtk-theme", temporary_theme)
time.sleep(0.05)
gsettings("set", schema, "gtk-theme", target_theme)
