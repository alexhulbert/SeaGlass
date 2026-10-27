#!/usr/bin/python3
import colorsys
import json
import math
import os
from pathlib import Path
import sys
import subprocess


PLUGIN = "seaglassCanvas"
BACKEND = "/usr/bin/matugen"
CALIBRATION = {
    "light": {"lightness_floor": 0.72, "saturation_boost": 0.5},
    "dark": {"lightness_ceiling": 0.28, "saturation_boost": 0.5},
}
SURFACES = (
    "background", "surface", "surface_variant", "surface_dim", "surface_bright",
    "surface_container_lowest", "surface_container_low", "surface_container",
    "surface_container_high", "surface_container_highest",
)


def bounded(value, default, low=0, high=100):
    try:
        number = float(value)
        return max(low, min(high, number)) if math.isfinite(number) else default
    except (ValueError, TypeError):
        return default


def read_settings():
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    try:
        values = json.loads((config / "DankMaterialShell/plugin_settings.json").read_text()).get(PLUGIN, {})
        return values if isinstance(values, dict) else {}
    except (OSError, ValueError):
        return {}


def profile(settings, mode, key):
    values = settings.get(mode)
    return bounded(values.get(key) if isinstance(values, dict) else None, 100)


def hls(color):
    value = color.removeprefix("#")
    return colorsys.rgb_to_hls(*(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4)))


def adjust(color, brightness, mode, calibration, fallback_hue):
    amount = 1 - brightness / 100
    if not amount:
        return color
    hue, lightness, saturation = hls(color)
    if mode == "light":
        # Preserve chroma so dimming near-white surfaces does not amplify their tint
        chroma = 2 * min(lightness, 1 - lightness) * saturation
        lightness += (min(lightness, calibration["lightness_floor"]) - lightness) * amount
        span = 2 * min(lightness, 1 - lightness)
        saturation = min(1, chroma * (1 + calibration["saturation_boost"] * amount) / span) if span else 0
    else:
        if saturation > 0 or fallback_hue is not None:
            if saturation == 0:
                hue = fallback_hue
            saturation += (1 - saturation) * calibration["saturation_boost"] * amount
        lightness += (max(lightness, calibration["lightness_ceiling"]) - lightness) * amount
    return "#" + "".join(f"{round(channel * 255):02x}" for channel in colorsys.hls_to_rgb(hue, lightness, saturation))


def native_palette(args):
    query, skip = [], False
    for arg in args:
        if not skip and arg not in ("--json", "-j", "--old-json-output") and not arg.startswith("--json="):
            query.append(arg)
        skip = not skip and arg in ("--json", "-j")
    result = subprocess.run([BACKEND, *query, "--dry-run", "--json", "hex", "--old-json-output"],
                            check=True, capture_output=True, text=True)
    return json.loads(result.stdout)


def render_import(args, settings):
    palette = native_palette(args)
    mode, colors = palette["mode"], palette["colors"]
    background = colors["background"]
    if background["default"] != background[mode]:
        mode = "light" if background["default"] == background["light"] else "dark"
    preset = (settings.get("preset") or {}).get("name")
    data = {"colors": {role: {} for role in SURFACES}}
    for variant in ("dark", "light", "default"):
        appearance = mode if variant == "default" else variant
        overrides = settings.get("calibration", {}).get(appearance, {})
        calibration = {key: bounded(overrides.get(key), value, 0, 1) for key, value in CALIBRATION[appearance].items()}
        seed = colors.get("source_color", colors.get("primary", {})).get(variant)
        hue = hls(seed)[0] if seed else None
        brightness = 100 if preset else profile(settings, appearance, "brightness")
        for role in SURFACES:
            color = adjust(colors[role][variant], brightness, appearance, calibration, hue)
            data["colors"][role][variant] = {"color": color}
    if preset == "reading":
        theme = json.loads((Path(__file__).resolve().parent / "canvas/themes/reading-sepia.json").read_text())
        ansi = {f"color{i}": {variant: {"color": color} for variant in ("dark", "light", "default")}
                for i, color in enumerate(theme["ansi"])}
        data.update(dank16=ansi, dank16term=ansi)
    data["canvas"] = {"frameless": preset in ("oled", "reading"), "blur": True}
    return data


def main():
    args = sys.argv[1:]
    if any(arg in args for arg in ("--version", "-V", "--help", "-h", "--dry-run", "--filter-docs-html")):
        os.execv(BACKEND, [BACKEND, *args])
    try:
        data = render_import(args, read_settings())
        args += ["--import-json-string", json.dumps(data, separators=(",", ":"))]
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print(f"Canvas adjustment skipped: {error}", file=sys.stderr)
    os.execv(BACKEND, [BACKEND, *args])


if __name__ == "__main__":
    main()
