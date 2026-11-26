local nixvars = require("vars")

hl.config({
    binds = {
        -- Pressing the active workspace's number returns to the previous one,
        -- matching Pond's workspace-auto-back-and-forth.
        workspace_back_and_forth = 1,
    },
})

local function app(cmd)
    return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

-- Check whether the active tiled window has another tiled window above/below
-- it in the same column, so Up/Down can replicate Niri's
-- focus-window-or-workspace and move-window-or-to-workspace behavior.
local function has_vertical_neighbor(dir)
    local w = hl.get_active_window()
    if not w or w.floating then
        return false
    end
    local wx1, wx2 = w.at.x, w.at.x + w.size.x
    for _, o in pairs(hl.get_windows({ workspace = w.workspace })) do
        if o.address ~= w.address and not o.floating then
            local ox1, ox2 = o.at.x, o.at.x + o.size.x
            if math.min(wx2, ox2) - math.max(wx1, ox1) > 10 then
                if (dir == "up" and o.at.y < w.at.y) or (dir == "down" and o.at.y > w.at.y) then
                    return true
                end
            end
        end
    end
    return false
end

local function step_workspace(delta, move_window)
    local ws = hl.get_active_workspace()
    if delta < 0 and ws and ws.id <= 1 then
        return
    end
    local target = delta > 0 and "r+1" or "r-1"
    if move_window then
        if hl.get_active_window() then
            hl.dispatch(hl.dsp.window.move({ workspace = target }))
        end
    else
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
end

-- Toggle the active column between full screen width (still on the scrollable
-- tape) and its previous width (defaulting to 0.85).
local saved_col_widths = {}
hl.on("window.close", function(w)
    if w and w.address then
        saved_col_widths[w.address] = nil
    end
end)

local function toggle_full_column()
    local w = hl.get_active_window()
    local m = hl.get_active_monitor()
    if not w or not m or w.floating then
        return
    end
    local usable = (m.width / m.scale) - (m.reserved.left or 0) - (m.reserved.right or 0)
    if usable <= 0 then
        return
    end
    local ratio = w.size.x / usable
    if ratio >= 0.95 then
        local prev = saved_col_widths[w.address] or 0.85
        saved_col_widths[w.address] = nil
        hl.dispatch(hl.dsp.layout(string.format("colresize %.3f", prev)))
    else
        saved_col_widths[w.address] = math.max(0.2, math.min(0.9, ratio))
        hl.dispatch(hl.dsp.layout("colresize 1.0"))
    end
end

-- Apps and session
hl.bind("SUPER + T", app("xdg-terminal-exec"))
hl.bind("SUPER + F", app('"$(xdg-settings get default-web-browser)"'))
-- vicinae runs as a user service and launches apps through uwsm itself.
hl.bind("SUPER + A", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("qs -c pond ipc call sidebar toggle"))
hl.bind("CTRL + SHIFT + Escape", app("xdg-terminal-exec btop"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --silent"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --silent"))

-- Discord Phoenix (GPUI/Wayland) intercepts close requests when minimize-to-tray
-- is enabled, leaving the window mapped on Hyprland; stash it in a special
-- workspace instead (or hide the special workspace if it is already there).
local function close_or_hide_window()
    local w = hl.get_active_window()
    if w and w.class == "com.discord.libdiscord" then
        if w.workspace and w.workspace.name == "special:discord" then
            hl.dispatch(hl.dsp.workspace.toggle_special("discord"))
        else
            hl.dispatch(hl.dsp.window.move({ workspace = "special:discord", follow = false }))
        end
    else
        hl.dispatch(hl.dsp.window.close())
    end
end

-- Windows
hl.bind("SUPER + Q", close_or_hide_window)
hl.bind("SUPER + V", hl.dsp.window.float())
hl.bind("SUPER + M", toggle_full_column)
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen())
hl.bind("SUPER + U", hl.dsp.focus({ urgent_or_last = true }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Columns: focus and move sideways along the strip; Up/Down moves within a
-- stacked column first and crosses into the workspace above/below at the edge.
for _, d in ipairs({
    { keys = { "left", "H" }, col = "l" },
    { keys = { "right", "L" }, col = "r" },
}) do
    for _, key in ipairs(d.keys) do
        hl.bind("SUPER + " .. key, hl.dsp.layout("focus " .. d.col))
        hl.bind("SUPER + CTRL + " .. key, hl.dsp.layout("swapcol " .. d.col))
    end
end
for _, d in ipairs({
    { keys = { "up", "K" }, dir = "up", delta = -1 },
    { keys = { "down", "J" }, dir = "down", delta = 1 },
}) do
    for _, key in ipairs(d.keys) do
        hl.bind("SUPER + " .. key, function()
            if has_vertical_neighbor(d.dir) then
                hl.dispatch(hl.dsp.focus({ direction = d.dir }))
            else
                step_workspace(d.delta, false)
            end
        end)
        hl.bind("SUPER + CTRL + " .. key, function()
            if has_vertical_neighbor(d.dir) then
                hl.dispatch(hl.dsp.window.swap({ direction = d.dir }))
            else
                step_workspace(d.delta, true)
            end
        end)
    end
end
hl.bind("SUPER + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind("SUPER + bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind("SUPER + comma", hl.dsp.layout("consume"))
hl.bind("SUPER + period", hl.dsp.layout("expel"))
hl.bind("SUPER + C", hl.dsp.layout("center"))
hl.bind("SUPER + CTRL + C", hl.dsp.layout("fit visible"))
hl.bind("SUPER + SHIFT + C", hl.dsp.layout("fit all"))
hl.bind("SUPER + R", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + CTRL + F", hl.dsp.layout("fit expand"))
hl.bind("SUPER + minus", hl.dsp.layout("colresize -0.1"), { repeating = true })
hl.bind("SUPER + equal", hl.dsp.layout("colresize +0.1"), { repeating = true })
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 60, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.layout("focus r"))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.layout("focus l"))
hl.bind("SUPER + CTRL + SHIFT + mouse_down", hl.dsp.layout("swapcol r"))
hl.bind("SUPER + CTRL + SHIFT + mouse_up", hl.dsp.layout("swapcol l"))

-- Workspaces stack vertically: the one below is always free.
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }))
for _, d in ipairs({
    { keys = { "Page_Down", "mouse_down" }, delta = 1 },
    { keys = { "Page_Up", "mouse_up" }, delta = -1 },
}) do
    for _, key in ipairs(d.keys) do
        hl.bind("SUPER + " .. key, function() step_workspace(d.delta, false) end)
        hl.bind("SUPER + CTRL + " .. key, function() step_workspace(d.delta, true) end)
    end
end
for i = 1, 10 do
    local key = i == 10 and "0" or tostring(i)
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + CTRL + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Monitors
for _, d in ipairs({
    { keys = { "left", "H" }, mon = "l" },
    { keys = { "right", "L" }, mon = "r" },
    { keys = { "up", "K" }, mon = "u" },
    { keys = { "down", "J" }, mon = "d" },
}) do
    for _, key in ipairs(d.keys) do
        hl.bind("SUPER + SHIFT + " .. key, hl.dsp.focus({ monitor = d.mon }))
        hl.bind("SUPER + SHIFT + CTRL + " .. key, hl.dsp.window.move({ monitor = d.mon }))
    end
end

-- Media keys also work on the lock screen.
local media = { locked = true }
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("qs -c pond ipc call volume increase"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("qs -c pond ipc call volume decrease"), held)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("qs -c pond ipc call volume muteOutput"), media)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("qs -c pond ipc call volume muteInput"), media)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), media)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), media)

-- Brightness keys drive the laptop backlight; DDC/CI monitors take them when
-- there is no backlight, and SUPER + brightness keys otherwise.
local ddc_mod = ""
if nixvars.laptop then
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), held)
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), held)
    hl.bind(
        "XF86KbdBrightnessUp",
        hl.dsp.exec_cmd(
            "sh -c 'b=$(brightnessctl -d \"*::kbd_backlight\" g); "
                .. "if [ \"$b\" -lt 33 ]; then n=33%; elif [ \"$b\" -lt 66 ]; then n=66%; "
                .. "elif [ \"$b\" -lt 100 ]; then n=100%; else n=0%; fi; "
                .. "brightnessctl -q -d \"*::kbd_backlight\" s \"$n\"'"
        ),
        media
    )
    ddc_mod = "SUPER + "
end
if nixvars.ddc then
    hl.bind(ddc_mod .. "XF86MonBrightnessUp", hl.dsp.exec_cmd("ddcutil --noverify setvcp 10 + 10"), held)
    hl.bind(ddc_mod .. "XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil --noverify setvcp 10 - 10"), held)
end
