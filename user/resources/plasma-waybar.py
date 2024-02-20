#!/usr/bin/env python3
import json
import os
import sys
import asyncio
from math import floor
from pyprland import ipc
import subprocess
import time

PLASMA_WINDOWED = 'plasmawindowed'

# Read the plasmoids.json file
config_home = os.environ.get('XDG_CONFIG_HOME', os.path.expanduser('~/.config'))
config_file = os.path.join(config_home, 'hypr', 'plasmoids.json')
with open(config_file) as f:
    config = json.load(f)

ipc.init()

def build_title(title):
    return f'^({title})$'

async def keep_plasma_running(first_plasmoid_id):
    cmd = f'{PLASMA_WINDOWED} {first_plasmoid_id}'
    # run command, restarting it if it quits
    while True:
        proc = await asyncio.create_subprocess_shell('killall plasmawindowed', env=os.environ, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
        await proc.wait()

        proc = await asyncio.create_subprocess_shell(cmd, env=os.environ, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
        await proc.wait()
        print("Plasmoid exited, restarting...")

async def start_plasmoids():
    started_first_plasmoid = False
    for plasmoid_name in config:
        cfg = config[plasmoid_name]
        plasmoid_id = cfg['plasmoid']
        title = build_title(cfg['title'])
        await asyncio.create_subprocess_shell(f'hyprctl keyword windowrulev2 "move 0 -200%,title:{title}"', env=os.environ),
        await asyncio.create_subprocess_shell(f'hyprctl keyword windowrulev2 "workspace special:scratch_{plasmoid_name} silent,title:{title}"', env=os.environ)
        await asyncio.create_subprocess_shell(f'hyprctl keyword windowrulev2 "size {cfg["width"]} {cfg["height"]}, title:{title}"', env=os.environ)
        if started_first_plasmoid:
            cmd = f'{PLASMA_WINDOWED} {plasmoid_id}'
            await asyncio.create_subprocess_shell(cmd, env=os.environ, stdout=asyncio.subprocess.DEVNULL, stderr=asyncio.subprocess.DEVNULL)
            pass
        else:
            asyncio.get_event_loop().create_task(keep_plasma_running(plasmoid_id))
            await asyncio.sleep(0.5)
            started_first_plasmoid = True

async def daemon():
    await start_plasmoids()
    while True:
        events, _ = await ipc.get_event_stream()
        while True:
            try:
                data = (await events.readline()).decode()
            except UnicodeDecodeError:
                print("Invalid unicode while reading events")
                continue
            asyncio.get_event_loop().create_task(handle_event(data))

async def handle_event(data):
    event_type = data.split('>>')[0]
    if event_type == 'workspace':
        # Hide all plasmoids when switching workspace
        monitor = await ipc.get_focused_monitor_props()
        windows = await ipc.hyprctlJSON('clients')
        for plasmoid_name in config:
            if await is_visible(plasmoid_name, monitor, windows):
                await hide(plasmoid_name)

async def is_visible(plasmoid_name, monitor=None, windows=None):
    if monitor is None:
        monitor = await ipc.get_focused_monitor_props()
    if windows is None:
        windows = await ipc.hyprctlJSON('clients')
    workspace = monitor['activeWorkspace']['id']
    for window in windows:
        if window['title'] == config[plasmoid_name]['title'] and window['workspace']['id'] == workspace:
            return True
    return False

async def toggle(plasmoid_name):
    if await is_visible(plasmoid_name):
        await hide(plasmoid_name)
    else:
        await show(plasmoid_name)

async def hide(plasmoid_name):
    cfg = config[plasmoid_name]
    monitor = await ipc.get_focused_monitor_props()

    title = build_title(cfg['title'])
    offset = floor(cfg['height'] * 1.3 + monitor['reserved'][1] + 8)

    await ipc.hyprctl(f'movewindowpixel 0 -{offset},title:{title}')
    await asyncio.sleep(0.2)
    await ipc.hyprctl(f'movetoworkspacesilent special:scratch_{plasmoid_name},title:{title}')

async def show(plasmoid_name):
    cfg = config[plasmoid_name]
    monitor = await ipc.get_focused_monitor_props()
    windows = await ipc.hyprctlJSON('clients')
    workspace = monitor['activeWorkspace']['id']

    title = build_title(cfg['title'])
    x_relative = floor(monitor['width'] / monitor['scale'] - cfg['width'] - cfg['margin_right'])
    x_pos = monitor['x'] + x_relative
    y_pos = monitor['y'] + monitor['reserved'][1] + 8

    for other_plasmoid in config:
        if other_plasmoid == plasmoid_name:
            continue
        if await is_visible(other_plasmoid, monitor, windows):
            await hide(other_plasmoid)

    await ipc.hyprctl(f'animations:enabled 0', 'keyword')
    await ipc.hyprctl([
        f'moveworkspacetomonitor special:scratch_{plasmoid_name} {monitor["name"]}',
        f'movetoworkspacesilent {workspace},title:{title}',
        f'movewindowpixel exact {x_pos} -200%,title:{title}'
    ])
    await asyncio.sleep(0.017)
    await ipc.hyprctl(f'animations:enabled 1', 'keyword')
    await ipc.hyprctl(f'movewindowpixel exact {x_pos} {y_pos},title:{title}')
    if not await is_visible(plasmoid_name, monitor): # fallback
        await asyncio.create_subprocess_shell(f'{PLASMA_WINDOWED} {cfg["plasmoid"]}', env=os.environ)
        await asyncio.sleep(1.5)
        await show(plasmoid_name)

async def main():
    if len(sys.argv) == 3:
        command = sys.argv[1]
        arg = sys.argv[2]
        if command == 'show':
            await show(arg)
        elif command == 'hide':
            await hide(arg)
        elif command == 'toggle':
            await toggle(arg)
    else:
        await asyncio.sleep(5)
        await daemon()

asyncio.run(main())
