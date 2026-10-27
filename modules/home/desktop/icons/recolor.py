#!/usr/bin/python
"""Recolor Papirus folders and YAMIS apps with the current desktop palette."""

import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


def update_icons(source, destination, palette_file):
    palette = json.loads(palette_file.read_text()) if palette_file.exists() else {}
    for colors in palette.values():
        for color in colors.values():
            if not re.fullmatch(r"#[0-9a-fA-F]{6}", color):
                raise ValueError(f"Invalid icon color: {color!r}")
    themes = [("Papirus-Colors", "light"), ("Papirus-Colors-Dark", "dark")]
    destination.mkdir(parents=True, exist_ok=True)
    with (destination / ".lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        stamp = destination / ".palette.json"
        state = [str(source), palette, Path(__file__).stat().st_mtime_ns]
        previous = json.loads(stamp.read_text()) if stamp.exists() else []
        if previous == state and all((destination / name / "index.theme").exists() for name, _ in themes):
            return
        for name, mode in themes:
            target = destination / name
            if not previous or previous[0] != str(source):
                shutil.rmtree(target, ignore_errors=True)
            colors = {"Text": "#232629" if mode == "light" else "#eff0f1", **palette.get(mode, {})}
            for path in (source / name).rglob("*"):
                output = target / path.relative_to(source / name)
                if path.is_dir():
                    output.mkdir(parents=True, exist_ok=True)
                    continue
                output.parent.mkdir(parents=True, exist_ok=True)
                if path.is_symlink():
                    if output.is_symlink() and os.readlink(output) == os.readlink(path):
                        continue
                    output.unlink(missing_ok=True)
                    output.symlink_to(os.readlink(path))
                    continue
                data = path.read_bytes()
                if path.suffix == ".svg":
                    data = re.sub(
                        r"(\.ColorScheme-(\w+)\s*\{\s*color:\s*)(#[0-9a-fA-F]{6})",
                        lambda m: m[1] + colors.get(m[2], m[3]), data.decode(),
                    ).encode()
                if output.is_file() and not output.is_symlink() and output.read_bytes() == data:
                    continue
                temporary = output.with_name(output.name + ".tmp")
                temporary.write_bytes(data)
                temporary.replace(output)
            (target / "index.theme").touch()
            subprocess.run(["/usr/bin/gtk-update-icon-cache", "--force", "--ignore-theme-index", str(target)], check=True)
        temporary = stamp.with_suffix(".tmp")
        temporary.write_text(json.dumps(state))
        temporary.replace(stamp)


if __name__ == "__main__":
    update_icons(*(Path(arg) for arg in sys.argv[1:4]))
