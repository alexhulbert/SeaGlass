local COL_ASPECT = 8 / 9
local SCROLL_SCALE = 2
local state_home = os.getenv("XDG_STATE_HOME") or os.getenv("HOME") .. "/.local/state"
local state_path = state_home .. "/hyprland-layout"
local saved = io.open(state_path)
local mode = saved and saved:read("*l") == "scrolling" and "scrolling" or "dwindle"
if saved then saved:close() end

local seen = {}
local panning = false

local function layout(message)
    hl.dispatch(hl.dsp.layout(message))
end

local function capacity(monitor)
    local width, height = monitor.width, monitor.height
    if monitor.transform % 2 == 1 then width, height = height, width end
    return math.max(1, math.floor(width / (height * COL_ASPECT) + 0.5))
end

local function refresh()
    local ws, window = hl.get_active_workspace(), hl.get_active_window()
    if mode ~= "scrolling" or not ws or not ws.monitor or ws.tiled_layout ~= "scrolling" or hl.get_active_special_workspace()
        or not window or window.floating or window.workspace ~= ws then return end
    local n, count, last = capacity(ws.monitor), 0, seen[ws.id]
    for _, w in ipairs(hl.get_windows({ workspace = ws, floating = false, mapped = true })) do
        local column = w.layout and w.layout.column
        if column and column.index then count = math.max(count, column.index + 1) end
    end
    if count == 0 or (last and not last.dirty and last.limit == n and last.count == count) then return end
    if count <= n then
        layout("fit all")
    elseif not last or last.limit ~= n or last.count < n then
        layout("colresize all " .. 1 / n)
    end
    seen[ws.id] = { limit = n, count = count }
end

local timer
local function schedule(ws)
    if ws and seen[ws.id] then seen[ws.id].dirty = true end
    if not (timer and timer:is_enabled()) then timer = hl.timer(refresh, { timeout = 1, type = "oneshot" }) end
end

local function scroll(event)
    local ws = hl.get_active_workspace()
    if not ws or ws.tiled_layout ~= "scrolling" or hl.get_active_special_workspace() then return end
    local m, left, right = ws.monitor, math.huge, -math.huge
    for _, w in ipairs(hl.get_windows({ workspace = ws, floating = false })) do
        if w.layout and not w.hidden then left, right = math.min(left, w.at.x), math.max(right, w.at.x + w.size.x) end
    end
    local gaps, border = hl.get_config("general.gaps_out"), hl.get_config("general.border_size")
    local width = (m.transform % 2 == 1 and m.height or m.width) / m.scale
    local minimum = m.x + width - m.reserved.right - gaps.right - border - right
    local maximum = m.x + m.reserved.left + gaps.left + border - left
    if minimum > maximum then return end
    local delta = math.max(minimum, math.min(maximum, event.delta.x * SCROLL_SCALE))
    if math.abs(delta) < 0.5 then return end
    panning = true
    layout("move " .. string.format("%+.3f", delta))
    panning = false
    layout("inhibit_scroll false")
end

local function gestures(unset)
    local scrolling = mode == "scrolling"
    hl.gesture({ fingers = 3, direction = "horizontal", action = unset and "unset" or scrolling and { update = scroll } or "workspace" })
    if scrolling then hl.gesture({ fingers = 4, direction = "horizontal", action = unset and "unset" or "workspace" }) end
end

local function apply()
    hl.config({ general = { layout = mode }, scrolling = { fullscreen_on_one_column = true, focus_fit_method = 1 } })
    gestures(false)
    seen = {}
    schedule()
end

local function toggle()
    local next_mode = mode == "dwindle" and "scrolling" or "dwindle"
    os.execute("mkdir -p -- '" .. state_home:gsub("'", "'\\''") .. "'")
    local file = assert(io.open(state_path .. ".tmp", "w"))
    assert(file:write(next_mode .. "\n"))
    assert(file:close())
    assert(os.rename(state_path .. ".tmp", state_path))
    gestures(true)
    mode = next_mode
    apply()
    hl.exec_scheduled_prop_refresh_immediately()
    hl.dispatch(hl.dsp.event("seaglass-layout"))
end

hl.on("window.open_early", function(window)
    if mode == "scrolling" and not window.floating and window.monitor then
        hl.config({ scrolling = { column_width = 1 / capacity(window.monitor) } })
    end
end)
for _, event in ipairs({ "window.open", "window.close", "window.move_to_workspace" }) do
    hl.on(event, function(window)
        if not window.floating then schedule(window.workspace) end
    end)
end
for _, event in ipairs({ "workspace.active", "workspace.move_to_monitor", "monitor.layout_changed" }) do
    hl.on(event, function() schedule() end)
end
hl.on("window.active", function()
    if panning then layout("inhibit_scroll true") end
    schedule()
end)
hl.on("workspace.removed", function(ws)
    if ws.id then seen[ws.id] = nil end
end)
hl.on("config.reloaded", function()
    hl.timer(function()
        if mode ~= "scrolling" then return end
        for _, name in ipairs({ "dwindle", "scrolling" }) do
            hl.config({ general = { layout = name } })
            hl.exec_scheduled_prop_refresh_immediately()
        end
        seen = {}
        schedule()
    end, { timeout = 1, type = "oneshot" })
end)

apply()

return { toggle = toggle, refresh = schedule }
