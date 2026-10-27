import json, sys

MOD = ""
ORDER = ["Applications", "Windows", "Workspaces", "Screenshots", "Voice", "Session", "Media"]
NAMES = {"SUPER": MOD, "mouse:272": "Left drag", "mouse:273": "Right drag", "F24": f"Copilot / Right {MOD}", "XF86Calculator": "Caps Lock"}
EXTRAS = {"Workspaces": [{"key": "3-finger swipe", "desc": "Switch workspace"}]}

binds = {}
for line in sys.stdin:
    key, _, desc = line.rstrip("\n").partition("\t")
    category, _, text = desc.partition(": ")
    if not text:
        continue
    key = "+".join(NAMES.get(part, part) for part in key.replace(" ", "").split("+"))
    rows = binds.setdefault(category, [])
    if {"key": key, "desc": text} not in rows:
        rows.append({"key": key, "desc": text})
for category, rows in EXTRAS.items():
    binds.setdefault(category, []).extend(rows)
ordered = sorted(binds, key=lambda c: (ORDER.index(c) if c in ORDER else len(ORDER), c))
json.dump({"title": "Seaglass shortcuts", "binds": {c: binds[c] for c in ordered}}, sys.stdout, indent=2, ensure_ascii=False)
