hl.layer_rule({ name = "vicinae-blur", match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "vicinae-no-anim", match = { namespace = "vicinae" }, no_anim = true })
-- Pond's shell animates its own panels and asks for blur on its cards through
-- ext-background-effect, as on Niri. Hyprland's open and close animations
-- replay on top of that, and while a layer fades out its blur spills past the
-- card it belongs to.
hl.layer_rule({ name = "pond-no-anim", match = { namespace = "pond-.*" }, no_anim = true })

-- Compact tools open at half width on 1080p so they pair naturally beside a
-- browser or editor without crowding out wider apps (which default to 0.85).
hl.window_rule({
    name = "scrolling-compact-apps",
    match = { class = "^(com\\.mitchellh\\.ghostty|org\\.gnome\\.Nautilus)$" },
    scrolling_width = 0.5,
})

-- Chromium/Helium extension popups map with an internal `_crx_<id>` (or
-- `chrome-extension://`) initial title before updating to the extension's name,
-- so static rules like `float` must match `initial_title`.
hl.window_rule({
    name = "chrome-extensions-float",
    match = { initial_title = "^(_crx_|chrome-extension://).*$" },
    float = true,
    center = true,
})

-- Native Hyprland and portal dialogs should always float as compact Pond-styled
-- cards rather than tiling into the scrolling layout.
hl.window_rule({
    name = "pond-polkit",
    match = { class = "^hyprpolkitagent$" },
    float = true,
    center = true,
    rounding = 16,
    border_size = 1,
    border_color = "rgba(f9efff1a)",
})
hl.window_rule({
    name = "pond-share-picker",
    match = { class = "^hyprland-share-picker$" },
    float = true,
    center = true,
    size = "500 320",
    rounding = 16,
    border_size = 1,
    border_color = "rgba(f9efff1a)",
})
hl.window_rule({
    name = "pond-portal-gtk",
    match = { class = "^xdg-desktop-portal-gtk$" },
    float = true,
    center = true,
    rounding = 16,
})
