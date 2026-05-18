local function app(cmd)
    return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

local function keys(...)
    local args = table.pack(...)
    return table.concat(args, " + ")
end

MAINMOD = "SUPER"

hl.bind(keys(MAINMOD, "Q"), hl.dsp.window.close())
hl.bind(keys(MAINMOD, "W"), hl.dsp.window.float())
hl.bind(keys("ALT", "RETURN"), hl.dsp.window.fullscreen())
hl.bind(
    keys("CTRL", "ALT", "DELETE"),
    hl.dsp.exec_cmd("loginctl terminate-session $XDG_SESSION_ID")
)

hl.bind(keys(MAINMOD, "F"), app(VARS.programs.browser))
hl.bind(keys(MAINMOD, "T"), app(VARS.programs.terminal))
hl.bind(keys(MAINMOD, "C"), app(VARS.programs.editor))
hl.bind(keys(MAINMOD, "E"), app(VARS.programs.file))

hl.bind(keys(MAINMOD, "A"), app("rofi -show drun"))
hl.bind(keys(MAINMOD, "R"), app("rofi -config ~/.config/rofi/run.rasi -show coolrun"))
hl.bind(keys(MAINMOD, "TAB"), app("rofi -show window"))

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

for i = 1,10 do
    local num = i == 10 and "0" or tostring(i)
    hl.bind(keys(MAINMOD, num), hl.dsp.focus({ workspace = i }))
    hl.bind(keys(MAINMOD, "SHIFT", num), hl.dsp.window.move({ workspace = i }))
    hl.bind(keys(MAINMOD, "ALT", num), hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(keys(MAINMOD, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(keys(MAINMOD, "mouse:273"), hl.dsp.window.resize(), { mouse = true })
hl.bind(keys(MAINMOD, "Z"), hl.dsp.window.drag())
hl.bind(keys(MAINMOD, "X"), hl.dsp.window.resize())

hl.bind(keys(MAINMOD, "S"), hl.dsp.workspace.toggle_special("magic"))
hl.bind(keys(MAINMOD, "ALT", "S"), hl.dsp.window.move({ workspace = "special:magic", follow = false }))

-- intereferes with screenshot, muscle memory's too strong to switch back now ahahah
-- hl.bind(keys(MAINMOD, "SHIFT", "S"), hl.dsp.window.move({ workspace = "special:magic" }))
