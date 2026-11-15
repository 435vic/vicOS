hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "altgr-intl",
        ["touchpad.natural_scroll"] = true,
        numlock_by_default = true,
    },
})

hl.bind("SUPER + T", hl.dsp.exec_cmd("uwsm app -- xdg-terminal-exec"))
hl.bind("SUPER + E", hl.dsp.exec_cmd('uwsm app -- xdg-open "$HOME"'))
hl.bind("SUPER + A", hl.dsp.exec_cmd("uwsm app -- rofi -show drun"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("uwsm app -- rofi -show drun"))
hl.bind("SUPER + F", hl.dsp.exec_cmd('uwsm app -- "$(xdg-settings get default-web-browser)"'))
hl.bind("SUPER + C", hl.dsp.exec_cmd('uwsm app -- "$(xdg-mime query default text/plain)"'))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + W", hl.dsp.window.float())
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen())
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("uwsm stop"))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

for i = 1, 10 do
    local key = i == 10 and "0" or tostring(i)
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Fleet-specific monitors and workspace placement are optional, not the entry point.
local machine_path = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/hypr/machine.lua"
local machine = io.open(machine_path, "r")
if machine then
    machine:close()
    dofile(machine_path)
end
