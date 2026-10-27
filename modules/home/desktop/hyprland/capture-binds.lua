-- Extracts keybind descriptions from hyprland configuration
local config, home = arg[1], arg[2]
local stub = setmetatable({}, { __index = function(t) return t end, __call = function(t) return t end })
hl = setmetatable({
    bind = function(key, _, options) io.write(key, "\t", options and options.description or "", "\n") end,
    define_submap = function(_, body) body() end,
    plugin = { darkwindow = stub, confined_floats = stub },
}, { __index = function() return stub end })
os.getenv = function() return home end
package.preload["dms.layout"] = function() end
package.path = config .. "/?.lua;" .. package.path
dofile(config .. "/hyprland.lua")
