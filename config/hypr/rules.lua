hl.layer_rule({ name = "vicinae-blur", match = { namespace = "vicinae" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "vicinae-no-anim", match = { namespace = "vicinae" }, no_anim = true })
-- Pond's shell animates its own panels and asks for blur on its cards through
-- ext-background-effect, as on Niri. Hyprland's open and close animations
-- replay on top of that, and while a layer fades out its blur spills past the
-- card it belongs to.
hl.layer_rule({ name = "pond-no-anim", match = { namespace = "pond-.*" }, no_anim = true })
