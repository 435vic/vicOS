-- Niri-style scrolling: each workspace is a horizontal strip of columns, and
-- workspaces stack vertically.
hl.config({
    general = {
        layout = "scrolling",
        gaps_in = 3,
        gaps_out = 8,
        border_size = 0,
    },
    scrolling = { wrap_focus = false, wrap_swapcol = false },
    decoration = {
        rounding = 10,
        shadow = { enabled = false },
        blur = { enabled = true },
    },
    animations = { enabled = true },
})

-- Everything animates with one quick ease-out curve. Speed is in tenths of a
-- second and inherited by every animation below "global".
hl.curve("easeOutCubic", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })
hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "easeOutCubic", style = "gnomed" })
-- slidevert also makes the workspace swipe gesture move vertically.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slidevert" })
