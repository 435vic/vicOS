local nixvars = require("vars")

local function app(cmd)
    return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

-- Apps and session
hl.bind("SUPER + T", app("xdg-terminal-exec"))
hl.bind("SUPER + F", app('"$(xdg-settings get default-web-browser)"'))
-- vicinae runs as a user service and launches apps through uwsm itself.
hl.bind("SUPER + A", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind("CTRL + SHIFT + Escape", app("xdg-terminal-exec btop"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-- Windows
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float())
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen())
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Columns: focus and move sideways; windows within a column go up and down.
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
    { keys = { "up", "K" }, dir = "up" },
    { keys = { "down", "J" }, dir = "down" },
}) do
    for _, key in ipairs(d.keys) do
        hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = d.dir }))
        hl.bind("SUPER + CTRL + " .. key, hl.dsp.window.swap({ direction = d.dir }))
    end
end
hl.bind("SUPER + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind("SUPER + bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind("SUPER + comma", hl.dsp.layout("consume"))
hl.bind("SUPER + period", hl.dsp.layout("expel"))
hl.bind("SUPER + C", hl.dsp.layout("center"))
hl.bind("SUPER + R", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + CTRL + F", hl.dsp.layout("fit expand"))
hl.bind("SUPER + minus", hl.dsp.layout("colresize -0.1"), { repeating = true })
hl.bind("SUPER + equal", hl.dsp.layout("colresize +0.1"), { repeating = true })
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.layout("focus r"))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.layout("focus l"))

-- Workspaces stack vertically: the one below is always free.
for _, d in ipairs({
    { keys = { "Page_Down", "U", "mouse_down" }, ws = "r+1" },
    { keys = { "Page_Up", "I", "mouse_up" }, ws = "r-1" },
}) do
    for _, key in ipairs(d.keys) do
        hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = d.ws }))
        hl.bind("SUPER + CTRL + " .. key, hl.dsp.window.move({ workspace = d.ws }))
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
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), held)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), media)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"), media)
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
    ddc_mod = "SUPER + "
end
if nixvars.ddc then
    hl.bind(ddc_mod .. "XF86MonBrightnessUp", hl.dsp.exec_cmd("ddcutil --noverify setvcp 10 + 10"), held)
    hl.bind(ddc_mod .. "XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil --noverify setvcp 10 - 10"), held)
end
