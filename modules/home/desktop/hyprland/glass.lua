local opacity = 1
local file = io.open((os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/hypr/dms/canvas-opacity")
if file then
    local dark, light = file:read("*n", "*n")
    file:close()
    opacity = <* if {{ is_dark_mode }} *>dark<* else *>light<* endif *> or 1
end

hl.config({
    decoration = not {{canvas.blur}} and { blur = { enabled = false, noise = 0 }, shadow = { enabled = false } } or nil,
    general = {
        border_size = <* if {{ canvas.frameless }} *>0<* else *><* if {{ is_dark_mode }} *>2<* else *>3<* endif *><* endif *>,
        <* if {{ canvas.frameless }} *>
        gaps_in = 0,
        gaps_out = 0,
        <* endif *>
        col = {
            inactive_border = "rgba({{colors.background.default.red}},{{colors.background.default.green}},{{colors.background.default.blue}}," .. opacity .. ")",
            active_border = {
                colors = {
                    "rgb({{colors.primary.default.hex | to_color | set_saturation: 75.0 | set_lightness: 65.0 | format: "hex_stripped"}})",
                    "rgb({{colors.tertiary.default.hex | to_color | set_saturation: 75.0 | set_lightness: 65.0 | format: "hex_stripped"}})",
                },
                angle = 45,
            },
        },
    },
})

if hl.plugin.darkwindow then
    local file = assert(io.open((os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/hypr/glass.glsl", "r"))
    hl.plugin.darkwindow.load_shader("glass", {
        source = file:read("*a"),
        args = {
            bkg = { {{colors.background.default.red}} / 255, {{colors.background.default.green}} / 255, {{colors.background.default.blue}} / 255 },
            glassTint = opacity,
        },
        introduces_transparency = true,
    })
    file:close()
    hl.window_rule({
        name = "window-glass",
        match = { fullscreen = false, initial_class = "negative:blender", class = "negative:^(Unity|org[.]gnome[.]Loupe)$" },
        ["darkwindow:shade"] = hl.plugin.darkwindow.build_rule_effect({ shader = "glass", args = { glassTint = opacity } }),
    })
end
