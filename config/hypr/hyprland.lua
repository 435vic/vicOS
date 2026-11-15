hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.bind("SUPER + T", hl.dsp.exec_cmd("uwsm app -- xdg-terminal-exec"))
hl.bind("SUPER + E", hl.dsp.exec_cmd('uwsm app -- xdg-open "$HOME"'))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + W", hl.dsp.window.float())
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen())
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("uwsm stop"))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

for i = 1, 10 do
    local key = i == 10 and "0" or tostring(i)
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
