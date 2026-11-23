hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "altgr-intl",
        ["touchpad.natural_scroll"] = true,
        numlock_by_default = true,
    },
})

-- Touchpad: swipe sideways along the columns, up and down between workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "scroll_move" })
hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })
