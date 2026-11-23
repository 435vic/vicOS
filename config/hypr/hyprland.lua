require("monitors")
require("look")
require("input")
require("rules")
require("keybinds")

hl.config {
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        middle_click_paste = false,
        key_press_enables_dpms = true,
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
    xwayland = {
        force_zero_scaling = true
    }
}

