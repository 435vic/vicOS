-- Niri-style scrolling: each workspace is a horizontal strip of columns, and
-- workspaces stack vertically.
hl.config({
    general = {
        layout = "scrolling",
        gaps_in = 3,
        gaps_out = 8,
        border_size = 2,
        ["col.active_border"] = "rgba(8a8a8a99)",
        ["col.inactive_border"] = "rgba(50505055)",
    },
    scrolling = {
        column_width = 0.90,
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
        -- Keep edges flush like Pond's center-focused-column "never"; use
        -- SUPER + C to center a column on demand.
        focus_fit_method = 1,
        wrap_focus = false,
        wrap_swapcol = false,
    },
    decoration = {
        rounding = 10,
        shadow = { enabled = false },
        -- A single Kawase pass at a large offset leaves diagonal cross-hatching
        -- over busy wallpapers; more passes at a smaller offset blur cleanly.
        blur = { enabled = true, size = 5, passes = 3 },
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
