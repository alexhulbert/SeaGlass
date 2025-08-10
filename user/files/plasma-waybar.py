#!/usr/bin/env python3
import json
import os
import sys
import asyncio
from pyprland import ipc
import subprocess

PLASMA_CMD = 'plasmawindowed'
PADDING = 20

# Load config
config_file = os.path.join(os.environ.get('XDG_CONFIG_HOME', '~/.config'), 'hypr/plasmoids.json')
with open(os.path.expanduser(config_file)) as f:
    config = json.load(f)

ipc.init()
is_active = False

async def hyprctl_keywords(*args):
    await ipc.hyprctl(list(args), 'keyword', logger=None)

async def hyprctl_dispatchers(*args):
    await ipc.hyprctl(list(args), logger=None)

async def hyprctl(cmd):
    await ipc.hyprctl(cmd, logger=None)

async def keep_plasma_running(plasmoid_id):
    while True:
        subprocess.run('killall plasmawindowed', shell=True, capture_output=True)
        try:
            proc = await asyncio.create_subprocess_shell(
                f'{PLASMA_CMD} {plasmoid_id}',
                stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.DEVNULL
            )
            await proc.wait()
        except Exception as e:
            print(f"Plasmoid error: {e}")
            await asyncio.sleep(1)

async def start_plasmoids():
    plasmoids = list(config.items())
    if plasmoids:
        asyncio.create_task(keep_plasma_running(plasmoids[0][1]['plasmoid']))
        await asyncio.sleep(0.5)
        for _, cfg in plasmoids[1:]:
            subprocess.Popen(f'{PLASMA_CMD} {cfg["plasmoid"]}', shell=True, 
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

async def daemon():
    await start_plasmoids()
    events, _ = await ipc.get_event_stream()
    async for line in events:
        try:
            await handle_event(line.decode())
        except UnicodeDecodeError:
            pass

async def handle_event(data):
    global is_active
    event, *parts = data.split('>>')
    
    if event == 'workspace':
        await hide_all()
    elif event == 'activewindow' and parts:
        window = parts[0].split(',')[1].strip()
        titles = [cfg['title'] for cfg in config.values()]
        
        if window in titles:
            is_active = True
        elif is_active:
            is_active = False
            await hyprctl_keywords('input:follow_mouse 1', 'input:float_switch_override_focus 1')
            await hide_all()

async def is_visible(name):
    monitor = await ipc.get_monitor_props()
    windows = await ipc.hyprctl_json('clients', logger=None)
    ws_id = monitor['activeWorkspace']['id']
    return any(w['title'] == config[name]['title'] and w['workspace']['id'] == ws_id 
               for w in windows)

async def hide(name, restore=True):
    title = f'^({config[name]["title"]})$'
    await hyprctl(f'movetoworkspacesilent special:scratch_{name},title:{title}')
    if restore:
        await hyprctl_keywords('input:follow_mouse 1', 'input:float_switch_override_focus 1')

async def hide_all(except_name=None, restore=True):
    for name in config:
        if name != except_name and await is_visible(name):
            await hide(name, restore)

async def show(name, retry=0):
    cfg = config[name]
    title = f'^({cfg["title"]})$'
    
    # Already visible? Just focus
    if await is_visible(name):
        await hyprctl(f'focuswindow title:{title}')
        await hide_all(name, restore=False)
        return
    
    # Get position
    monitor = await ipc.get_monitor_props()
    try:
        mouse = await ipc.hyprctl_json('cursorpos', logger=None)
        mx, my = mouse['x'], mouse['y']
    except:
        mx = my = 0
    
    scale = monitor['scale']
    x = max(monitor['x'] + PADDING, 
            min(mx - PADDING, monitor['x'] + monitor['width']/scale - cfg['width'] - PADDING))
    y = max(my - PADDING, monitor['y'] + monitor['reserved'][1] + PADDING)
    
    # Set focus mode and move window
    await hyprctl_keywords('cursor:no_warps 1', 'input:float_switch_override_focus 0', 'input:follow_mouse 2')
    await hyprctl_dispatchers(
        f'moveworkspacetomonitor special:scratch_{name} {monitor["name"]}',
        f'movetoworkspacesilent {monitor["activeWorkspace"]["id"]},title:{title}',
        f'movewindowpixel exact {int(x)} {int(y)},title:{title}',
        f'focuswindow title:{title}'
    )
    
    await hide_all(name, restore=False)
    await asyncio.sleep(0.016)  # One frame
    
    # Clear notifications if swaync is available
    if not subprocess.run(['which', 'swaync-client'], capture_output=True).returncode:
        subprocess.Popen(['swaync-client', '-cp'])
    
    # Spawn if needed
    if not await is_visible(name) and retry < 3:
        subprocess.Popen(f'{PLASMA_CMD} {cfg["plasmoid"]}', shell=True,
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        await asyncio.sleep(0.5)
        await show(name, retry + 1)

async def toggle(name):
    await (hide(name) if await is_visible(name) else show(name))

async def main():
    if len(sys.argv) == 1:
        await daemon()
    else:
        cmd = sys.argv[1]
        if cmd == 'hide-all':
            await hide_all()
        elif len(sys.argv) > 2:
            arg = sys.argv[2]
            await {'show': show, 'hide': hide, 'toggle': toggle}.get(cmd, lambda _: None)(arg)

asyncio.run(main())
