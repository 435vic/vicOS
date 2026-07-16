-- Hyprland's current windowrule syntax matches fields like class/title/tag and
-- then applies one or more rule properties. Keep match lists near the top so
-- adding another popup/floating window is just appending another matcher.

local function window_rule(name, match, properties)
    local spec = {
        name = name,
        match = match,
    }

    for key, value in pairs(properties) do
        spec[key] = value
    end

    hl.window_rule(spec)
end

local function tag_windows(tag, matches)
    for index, match in ipairs(matches) do
        window_rule(("tag-%s-%02d"):format(tag, index), match, {
            tag = "+" .. tag,
        })
    end
end

local function float_windows(matches)
    for index, match in ipairs(matches) do
        window_rule(("float-%02d"):format(index), match, {
            float = true,
        })
    end
end

local function popup_windows(matches)
    tag_windows("ephemeral", matches)
end

tag_windows("acrylic", {
    { class = "com.mitchellh.ghostty" },
})

tag_windows("acrylic2", {
    { class = "dev.zed.Zed" },
})

-- Popup-style windows: transient applets, dialogs, extension popups, and the
-- Microslop Ghostty surfaces launched by the desktop entry / restore watcher.
popup_windows({
    { title = "wiremix" },
    { title = "btop" },
    { class = "Bitwarden" },
    { class = "com.mitchellh.ghostty", title = "rmpc" },
    { class = "dev.boredvico.microslop" },
})

-- Plain floating windows keep their own size/position instead of the shared
-- popup sizing below.
float_windows({
    { class = "script-fu" },
    { class = "Tk" },
})

window_rule("packettracer-no-initial-focus", { class = "PacketTracer" }, {
    no_initial_focus = true,
})

window_rule("packettracer-main", { class = "PacketTracer", title = "Cisco Packet Tracer" }, {
    keep_aspect_ratio = true,
    focus_on_activate = true,
})

window_rule("packettracer-preferences-min-size", { class = "PacketTracer", title = "Preference" }, {
    min_size = "486 628",
})

window_rule("packettracer-router-min-size", { class = "PacketTracer", title = ".*outer.*" }, {
    min_size = "486 628",
})

window_rule("packettracer-switch-min-size", { class = "PacketTracer", title = ".*witch.*" }, {
    min_size = "772 700",
})

window_rule("packettracer-pc-min-size", { class = "PacketTracer", title = ".*PC.*" }, {
    min_size = "807 655",
})

window_rule("packettracer-save-file-min-size", { class = "PacketTracer", title = ".*Save File." }, {
    min_size = "791 648",
})

window_rule("acrylic", { tag = "acrylic" }, {
    opacity = 0.97,
})

window_rule("acrylic2", { tag = "acrylic2" }, {
    opacity = 0.98,
})

window_rule("ephemeral", { tag = "ephemeral" }, {
    float = true,
    center = true,
    opacity = 1,
    size = "(monitor_w*0.45) (monitor_h*0.45)",
})
