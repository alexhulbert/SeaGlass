#!/usr/bin/python3
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time


def run(*args, **kwargs):
    return subprocess.run(args, capture_output=True, text=True, check=True, **kwargs).stdout


def window():
    return json.loads(run("hyprctl", "activewindow", "-j"))


@contextmanager
def clipboard(text):
    types = subprocess.run(["wl-paste", "--list-types"], capture_output=True, text=True).stdout.splitlines()
    mime = next((m for m in ("text/plain;charset=utf-8", "text/plain", "image/png") if m in types), types[0] if types else "text/plain")
    previous = subprocess.run(["wl-paste", "--no-newline", "--type", mime], capture_output=True)
    try:
        subprocess.run(["wl-copy", "--sensitive", "--type", "text/plain"], input=text, text=True, check=True)
        yield
    finally:
        if previous.returncode == 0:
            subprocess.run(["wl-copy", "--type", mime], input=previous.stdout, check=True)
        else:
            run("wl-copy", "--clear")


def paste(text):
    with clipboard(text):
        run("dms", "cl", "send-paste")
        time.sleep(0.2)


def selection():
    marker = f"handy-edit-{os.getpid()}"
    with clipboard(marker):
        run("hyprctl", "eval", f'hl.dispatch(hl.dsp.send_shortcut({{mods="CTRL", key="C", window="address:{source["address"]}"}}))')
        for _ in range(25):
            text = run("wl-paste", "--no-newline")
            if text != marker:
                return text
            time.sleep(0.02)
        return ""


endpoint = Path(os.environ["XDG_RUNTIME_DIR"]) / "handy-edit.sock"
try:
    with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as channel:
        if sys.argv[1:]:
            text = sys.argv[1]
            try:
                channel.sendto(text.encode(), str(endpoint))
            except (FileNotFoundError, ConnectionRefusedError):
                if text:
                    paste(text)
            sys.exit()
        lock = open(endpoint.with_suffix(".lock"), "w")
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            if endpoint.exists():
                run("handy", "--toggle-transcription")
            sys.exit()
        source = window()
        terminal = "wezterm" in source["class"].lower() or source["class"].lower() in {"kitty", "alacritty", "foot"}
        selected = "" if terminal else selection()
        endpoint.unlink(missing_ok=True)
        channel.bind(str(endpoint))
        channel.settimeout(360)
        try:
            run("handy", "--toggle-transcription")
            instruction = channel.recv(1 << 20).decode().strip()
        finally:
            endpoint.unlink(missing_ok=True)
    if not instruction:
        sys.exit()
    task = f"Apply the instruction to the selected text.\n\nSelected text:\n{selected}" if selected else "Follow the instruction to generate text to insert at the cursor."
    prompt = f"{task}\n\nReturn only the resulting text, without commentary or code fences.\n\nInstruction:\n{instruction}"
    run("dms", "ipc", "call", "handyEdit", "show")
    try:
        result = run("codex", "exec", "--ignore-user-config", "--ephemeral", "--sandbox", "read-only",
                     "--skip-git-repo-check", "-C", "/tmp", "-m", "gpt-6.1-sol",
                     "-c", 'forced_login_method="chatgpt"', "-c", 'model_reasoning_effort="low"',
                     "-c", "features.shell_tool=false", "-", input=prompt, timeout=120).rstrip("\n")
    finally:
        run("dms", "ipc", "call", "handyEdit", "hide")
    if not result.strip():
        raise ValueError("Codex returned no text")
    run("hyprctl", "eval", f'hl.dispatch(hl.dsp.focus({{window="address:{source["address"]}"}}))')
    if window()["address"] != source["address"] or (selected and selection() != selected):
        raise ValueError("Selection changed; edit cancelled")
    paste(result)
except (OSError, subprocess.SubprocessError, ValueError, KeyError) as error:
    run("notify-send", "Voice edit failed", str(error))
    sys.exit(1)
