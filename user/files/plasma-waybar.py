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

GAP = 8
is_plasmoid_active = False

def build_title(title):
    return f'^({title})$'

async def restore_focus_props():
    await ipc.hyprctl([
        'input:follow_mouse 1',
        'input:float_switch_override_focus 1'
    ], 'keyword', logger=None)

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
    global is_plasmoid_active
    event_type = data.split('>>')[0]
    if event_type == 'workspace':
        # Hide all plasmoids when switching workspace
        monitor = await ipc.get_focused_monitor_props()
        windows = await ipc.hyprctl_json('clients', logger=None)
        for plasmoid_name in config:
            if await is_visible(plasmoid_name, monitor, windows):
                await hide(plasmoid_name)
    elif event_type == 'activewindow':
        # verify active window is not a plasmoid
        current_window = data.split('>>')[1].split(',')[1].strip()
        plasmoid_titles = [config[plasmoid_name]['title'] for plasmoid_name in config]
        if current_window in plasmoid_titles:
            if not is_plasmoid_active:
                await asyncio.sleep(1)
                is_plasmoid_active = True
        elif is_plasmoid_active:
            # Hide all plasmoids when switching window
            is_plasmoid_active = False
            await restore_focus_props()
            monitor = await ipc.get_focused_monitor_props()
            windows = await ipc.hyprctl_json('clients', logger=None)
            for plasmoid_name in config:
                if await is_visible(plasmoid_name, monitor, windows):
                    await hide(plasmoid_name)


async def is_visible(plasmoid_name, monitor=None, windows=None):
    if monitor is None:
        monitor = await ipc.get_focused_monitor_props()
    if windows is None:
        windows = await ipc.hyprctl_json('clients', logger=None)
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

async def hide_all(except_plasmoid=None, monitor=None, windows=None):
    if monitor is None:
        monitor = await ipc.get_focused_monitor_props()
    if windows is None:
        windows = await ipc.hyprctl_json('clients', logger=None)
    for other_plasmoid in config:
        if other_plasmoid == except_plasmoid:
            continue
        if await is_visible(other_plasmoid, monitor, windows):
            await hide(other_plasmoid)

async def hide(plasmoid_name):
    cfg = config[plasmoid_name]
    monitor = await ipc.get_focused_monitor_props()

    title = build_title(cfg['title'])
    offset = floor(cfg['height'] * 1.3 + monitor['reserved'][1] + GAP)

    await ipc.hyprctl(f'movewindowpixel 0 -{offset},title:{title}', logger=None)
    await asyncio.sleep(0.2)
    await ipc.hyprctl(f'movetoworkspacesilent special:scratch_{plasmoid_name},title:{title}', logger=None)
    await restore_focus_props()

async def show(plasmoid_name):
    cfg = config[plasmoid_name]
    monitor = await ipc.get_focused_monitor_props()
    workspace = monitor['activeWorkspace']['id']

    title = build_title(cfg['title'])
    x_relative = floor(monitor['width'] / monitor['scale'] - cfg['width'] - cfg['margin_right'])
    x_pos = monitor['x'] + x_relative
    y_pos = monitor['y'] + monitor['reserved'][1] + GAP

    await hide_all(plasmoid_name, monitor)

    await ipc.hyprctl([
        'cursor:no_warps 1',
        'animations:enabled 0',
        'input:float_switch_override_focus 0',
        'input:follow_mouse 2'
    ], 'keyword', logger=None)

    if subprocess.run(['which', 'swaync-client'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
        subprocess.Popen(['swaync-client', '-cp'])

    await ipc.hyprctl([
        f'moveworkspacetomonitor special:scratch_{plasmoid_name} {monitor["name"]}',
        f'movetoworkspacesilent {workspace},title:{title}',
        f'movewindowpixel exact {x_pos} -100%,title:{title}',
        f'focuswindow title:{title}'
    ], logger=None)
    await asyncio.sleep(0.017)
    await ipc.hyprctl([
        'cursor:no_warps 0',
        'animations:enabled 1'
    ], 'keyword', logger=None)
    await ipc.hyprctl(f'movewindowpixel exact {x_pos} {y_pos},title:{title}', logger=None)
    if not await is_visible(plasmoid_name, monitor): # fallback
        await asyncio.create_subprocess_shell(f'{PLASMA_WINDOWED} {cfg["plasmoid"]}', env=os.environ)
        await asyncio.sleep(1.5)
        await show(plasmoid_name)

async def main():
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == 'hide-all':
            await hide_all()
        else:
            arg = sys.argv[2]
            if command == 'show':
                await show(arg)
            elif command == 'hide':
                await hide(arg)
            elif command == 'toggle':
                await toggle(arg)
            else:
                print(f'Unknown command: {command}')
    else:
        await daemon()

asyncio.run(main())
