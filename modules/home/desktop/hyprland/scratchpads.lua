local sidebars = require("sidebars")
local pending = {}
local classes = {}

local function animation(name, leaf)
    local pad = sidebars[name]
    local monitor = hl.get_active_monitor()
    local width = (monitor.transform % 2 == 1 and monitor.height or monitor.width) / monitor.scale
    local distance = pad.width and math.ceil(100 * (pad.width + 2 * hl.get_config("general.border_size")) / width) or 60
    local direction = leaf == "specialWorkspaceIn" and pad.enter or pad.leave
    hl.animation({ leaf = leaf, enabled = true, speed = 7, bezier = "seaglass", style = "slide " .. direction .. " " .. distance .. "%" })
end

local function place(name, pad, window)
    local monitor = hl.get_active_monitor()
    local width, height = monitor.width / monitor.scale, monitor.height / monitor.scale
    if monitor.transform % 2 == 1 then width, height = height, width end
    local border = hl.get_config("general.border_size")
    local top = pad.width and monitor.reserved.top + border or math.floor(height * 0.4)
    local size = math.min(pad.width or width - 2 * border, width - 2 * border)
    local x = pad.enter == "right" and width - size - border or border
    local origin = window.monitor or monitor
    hl.dispatch(hl.dsp.window.move({ window = window, workspace = "special:" .. name, follow = false }))
    hl.dispatch(hl.dsp.window.resize({ window = window, x = size, y = height - top - border }))
    hl.dispatch(hl.dsp.window.move({ window = window, x = origin.x + x, y = origin.y + top }))
end

for name, pad in pairs(sidebars) do
    table.insert(classes, pad.class)
    hl.window_rule({
        name = "scratchpad-" .. name,
        match = { class = "^" .. pad.class .. "$" },
        workspace = "special:" .. name .. " silent",
        float = true,
        rounding = 0,
        render_unfocused = false,
    })
    hl.bind("SUPER + SHIFT + " .. pad.key, function()
        local active = hl.get_active_special_workspace()
        if active then
            local previous = active.name:gsub("^special:", "")
            if sidebars[previous] then animation(previous, "specialWorkspaceOut") end
            hl.dispatch(hl.dsp.workspace.toggle_special(previous))
            if previous == name then return end
        end
        animation(name, "specialWorkspaceIn")
        animation(name, "specialWorkspaceOut")
        local window = hl.get_windows({ class = pad.class })[1]
        if not window then
            pending[name] = true
            hl.exec_cmd(pad.command)
            return
        end
        place(name, pad, window)
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end, { description = "Applications: Show/hide " .. pad.label })
end

hl.on("window.open", function(window)
    for name, pad in pairs(sidebars) do
        if window.class == pad.class then
            place(name, pad, window)
            if pending[name] then
                pending[name] = nil
                hl.dispatch(hl.dsp.workspace.toggle_special(name))
            end
            return
        end
    end
end)

hl.on("hyprland.start", function()
    for _, pad in pairs(sidebars) do
        hl.exec_cmd(pad.command)
    end
end)

return { pattern = table.concat(classes, "|") }
