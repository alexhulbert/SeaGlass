local scratchpads = require("scratchpads")
local layouts = require("layouts")

hl.config({
    decoration = {
        blur = { enabled = true, noise = 0.07, xray = true, popups = true },
        shadow = { enabled = true, range = 8, render_power = 3, color = "rgba(000000d6)" },
    },
    input = { kb_layout = "us", follow_mouse = 1 },
    xwayland = { force_zero_scaling = false },
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    gestures = { workspace_swipe_cancel_ratio = 0.15 },
    binds = { workspace_back_and_forth = true, allow_workspace_cycles = true },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true, disable_splash_rendering = true },
})

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto", vrr = 1 })

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("uwsm finalize")
    hl.exec_cmd("uwsm app -s b -- /usr/lib/firefox/firefox about:blank", { workspace = "special:ffpreload silent" })
end)

hl.curve("seaglass", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "seaglass" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "layers", enabled = false })

hl.layer_rule({ match = { namespace = "^(dms:.*|quickshell|wayhud)$" }, no_anim = true })
hl.layer_rule({ match = { namespace = "^dms:notification.*$" }, no_screen_share = true })
hl.window_rule({ name = "glass", match = { class = ".*" }, opacity = 0.999 })
hl.window_rule({ name = "no-maximize", match = { class = ".*" }, suppress_event = "maximize" })
if hl.plugin.confined_floats then
    hl.window_rule({
        name = "confined-floats",
        match = { float = true, fullscreen = false, pin = false, class = "negative:^(" .. scratchpads.pattern .. "|)$" },
        ["confined-floats:confine"] = true,
    })
end
hl.window_rule({
    name = "quick-capture",
    match = { class = "^dev.duxlabs.shell$", title = "^Quick Capture$" },
    fullscreen = true,
})
hl.window_rule({ name = "pip", match = { title = "^Picture-in-Picture$" }, float = true, force_rgbx = true })
hl.window_rule({
    name = "sushi-preview",
    match = { class = "^org\\.gnome\\.NautilusPreviewer(\\.Devel)?$" },
    float = true,
    center = true,
})
hl.window_rule({
    name = "image-viewer",
    match = { class = "^org\\.gnome\\.Loupe$" },
    float = true,
    center = true,
    opacity = 1,
})
hl.window_rule({
    name = "private-firefox",
    match = { class = "^firefox$", title = ".*Private Browsing$" },
    no_screen_share = true,
})
hl.window_rule({
    name = "dialogs",
    match = { class = "^(1Password|pavucontrol-qt|org\\.freedesktop\\.impl\\.portal.*|xdg-desktop-portal.*|nm-connection-editor|TUI\\.float)$" },
    float = true,
})
hl.window_rule({
    name = "file-dialogs",
    match = { title = "^(Open File|Open Folder|Save As|Save File|Authentication Required)$" },
    float = true,
})
hl.window_rule({ name = "empty-dialogs", match = { class = "^$", title = "^$" }, float = true })
hl.window_rule({
    name = "xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})
hl.window_rule({ name = "blender-dialogs", match = { class = "blender" }, size = "1280 960", center = true })

hl.bind("SUPER + F", hl.dsp.window.fullscreen(), { description = "Windows: Toggle fullscreen" })
hl.bind("SUPER + W", hl.dsp.exec_cmd("uwsm app -- firefox"), { description = "Applications: Firefox" })
hl.bind("SUPER + Return", hl.dsp.exec_cmd("uwsm app -- wezterm"), { description = "Applications: Terminal" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Windows: Close window" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill(), { description = "Windows: Kill unresponsive window" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("dms ipc call lock lock"), { description = "Session: Lock screen" })
hl.bind("SUPER + M", hl.dsp.exec_cmd("uwsm stop"), { description = "Session: Log out" })
hl.bind("SUPER + E", hl.dsp.exec_cmd("uwsm app -- nautilus --new-window"), { description = "Applications: Files" })
hl.bind("SUPER + N", hl.dsp.exec_cmd("dms ipc call notepad toggle"), { description = "Applications: Notepad" })
hl.bind("SUPER + SHIFT + Space", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local window = hl.get_active_window()
    if window then layouts.refresh(window.workspace) end
    if not window or not window.floating then return end
    local monitor = window.monitor
    local width, height = monitor.width / monitor.scale, monitor.height / monitor.scale
    if monitor.transform % 2 == 1 then width, height = height, width end
    if window.size.x <= width * 0.7 and window.size.y <= height * 0.7 then return end
    hl.dispatch(hl.dsp.window.resize({
        x = math.min(window.size.x, width * 0.7), y = math.min(window.size.y, height * 0.7),
    }))
    hl.dispatch(hl.dsp.window.center())
end, { description = "Windows: Toggle floating" })
hl.bind("SUPER + D", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { description = "Applications: Launcher" })
hl.bind("SUPER + S", hl.dsp.exec_cmd("wayhud"), { description = "Applications: Search window menus" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Windows: Toggle split direction" })
hl.bind("SUPER + slash", hl.dsp.exec_cmd("dms ipc call keybinds toggle seaglass"), { description = "Session: Show these shortcuts" })
hl.bind("F24", hl.dsp.exec_cmd("handy --toggle-transcription"), { description = "Voice: Tap to start/stop dictation" })
hl.bind("ALT + F24", hl.dsp.exec_cmd("handy-edit"), { description = "Voice: Rewrite selected text" })
hl.bind("SUPER + comma", hl.dsp.exec_cmd("dms ipc call settings toggle"), { description = "Session: Settings" })
if hl.plugin.darkwindow then
    hl.bind("SUPER + O", hl.plugin.darkwindow.dsp_shade({
        shader = "glass", args = { glassTint = 1 },
    }), { description = "Windows: Make window opaque" })
end

for _, direction in ipairs({ "left", "right", "up", "down" }) do
    hl.bind("SUPER + " .. direction, hl.dsp.focus({ direction = direction }), { description = "Windows: Focus a window" })
    hl.bind("SUPER + SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }), { description = "Windows: Move a window" })
end
for workspace = 1, 9 do
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace, on_current_monitor = true }), { description = "Workspaces: Go to workspace " .. workspace })
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }), { description = "Workspaces: Move window to workspace " .. workspace })
end
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10, on_current_monitor = true }), { description = "Workspaces: Go to workspace 10" })
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }), { description = "Workspaces: Move window to workspace 10" })
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1", on_current_monitor = true }), { description = "Workspaces: Previous/next workspace" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1", on_current_monitor = true }), { description = "Workspaces: Previous/next workspace" })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Windows: Drag window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Windows: Resize window" })
hl.bind("XF86Calculator", hl.dsp.focus({ workspace = "previous", on_current_monitor = true }), { description = "Workspaces: Previous workspace" })
hl.bind("CTRL + bracketleft", hl.dsp.exec_cmd("wtype -k Escape"), { description = "Session: Escape" })
hl.bind("SUPER + Escape", hl.dsp.submap("empty"), { description = "Session: Disable/enable shortcuts" })
hl.define_submap("empty", function()
    hl.bind("SUPER + Escape", hl.dsp.submap("reset"), { description = "Session: Disable/enable shortcuts" })
end)

hl.bind("XF86PowerOff", hl.dsp.exec_cmd("dms ipc call powermenu toggle"), { description = "Power menu" })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 5"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 5"), { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), { locked = true, description = "Mute speakers" })
hl.bind("SUPER + XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio cycleoutput"), { description = "Media: Cycle audio output" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call mic mute"), { locked = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl --class=backlight --min-value=0 set +5%"), { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --class=backlight --min-value=0 set 5%-"), { locked = true, repeating = true, description = "Brightness down" })
hl.bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl --class=backlight --min-value=0 set 100%"), { locked = true, description = "Maximum brightness" })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --class=backlight --min-value=0 set 0%"), { locked = true, description = "Minimum brightness" })
hl.bind("SUPER + P", hl.dsp.exec_cmd("uwsm app -- wezterm start --class TUI.float -- hyprmoncfg"), { description = "Session: Monitor profiles" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player=spotify,%any,kdeconnect play-pause"), { locked = true, description = "Play/pause" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --player=spotify,%any,kdeconnect next"), { locked = true, description = "Next track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --player=spotify,%any,kdeconnect previous"), { locked = true, description = "Previous track" })
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl --player=spotify,%any,kdeconnect next"), { description = "Media: Next/previous track" })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl --player=spotify,%any,kdeconnect previous"), { description = "Media: Next/previous track" })
hl.bind("SHIFT + XF86AudioNext", hl.dsp.exec_cmd("playerctl --player=spotify,%any,kdeconnect shuffle Toggle"), { description = "Media: Toggle shuffle" })
hl.bind("Print", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot region edit"), { description = "Screenshots: Capture region" })
hl.bind("SUPER + Print", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot window edit"), { description = "Screenshots: Capture window" })
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("dms ipc call quickCapture screenshot full edit"), { description = "Screenshots: Capture monitor" })

require("dms.layout")
hl.config({ decoration = { blur = { size = 3, passes = 5 } } })

for _, fragment in ipairs({ "colors", "cursor", "input", "binds-user", "windowrules", "glass", "profile" }) do
    local path = os.getenv("HOME") .. "/.config/hypr/dms/" .. fragment .. ".lua"
    local file = io.open(path)
    if file then
        file:close()
        dofile(path)
    end
end

-- Added by hyprmoncfg
do local path = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
