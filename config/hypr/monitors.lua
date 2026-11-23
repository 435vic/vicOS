local nixvars = require("vars")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

for _, monitor in ipairs(nixvars.monitors or {}) do
    hl.monitor(monitor)
end

-- Monitor rules are registered above; create the configured headless outputs
-- afterwards so Hyprland applies those rules on creation.
for _, output in ipairs(nixvars.virtual or {}) do
    if hl.get_monitor(output) == nil then
        hl.exec_cmd("hyprctl output create headless " .. output)
    end
end

if nixvars.primary then
    for i = 1, 10 do
        hl.workspace_rule({ workspace = tostring(i), monitor = nixvars.primary, default = i == 1, persistent = i == 1 })
    end
end
