import copy
import fcntl
import json
import os
from pathlib import Path
import re
import socket
import sys

runtime = Path(os.environ["XDG_RUNTIME_DIR"])
lock = (runtime / "dms-cast-resolution.lock").open("w")
fcntl.flock(lock, fcntl.LOCK_EX)
state_file = runtime / "dms-cast-resolution.json"
mode = sys.argv[1] if len(sys.argv) > 1 else ""
if not mode and not state_file.exists():
    sys.exit(0)

connection = socket.socket(socket.AF_UNIX)
connection.settimeout(20)
connection.connect(str(runtime / "hyprmoncfgd.sock"))
stream = connection.makefile("rwb")


def call(method, params=None):
    request = dict(type="request", protocol_version=1, id=method, method=method, params=params)
    stream.write((json.dumps(request) + "\n").encode())
    stream.flush()
    reply = json.loads(stream.readline())
    if reply.get("error"):
        raise RuntimeError(reply["error"]["message"])
    return reply.get("result")


def apply(profile):
    transaction = call("preview", dict(profile=profile, timeout_seconds=15))
    try:
        call("confirm", dict(transaction_id=transaction["id"]))
    except Exception:
        call("revert", dict(transaction_id=transaction["id"]))
        raise


status = call("status")
if mode:
    match = re.fullmatch(r"(\d+)x(\d+)@(\d+(?:\.\d+)?)(?:Hz)?", mode)
    if not match:
        raise ValueError("resolution must be WIDTHxHEIGHT@HZ")
    editor = call("editor_state")
    profile = editor["profile"]
    profile["name"] = status["daemon"].get("profile_override", "Cast")
    if not state_file.exists():
        state_file.write_text(json.dumps(dict(profile=profile, auto="profile_override" not in status["daemon"], hardware=editor["monitor_set_hash"])))
    target = copy.deepcopy(profile)
    target["name"] = "Cast"
    focused = next(display["key"] for display in editor["displays"] if display["focused"])
    output = next(output for output in target["outputs"] if output["key"] == focused)
    output.update(mode=mode, width=int(match[1]), height=int(match[2]), refresh=float(match[3]))
    apply(target)
else:
    state = json.loads(state_file.read_text())
    if status["daemon"].get("profile_override") == "Cast" and status["monitor_set_hash"] == state["hardware"]:
        apply(state["profile"])
        if state["auto"]:
            call("set_profile_auto", dict(enabled=True))
    state_file.unlink()
