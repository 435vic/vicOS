MAINMOD = "SUPER"

local defaults = {
    programs = {
        terminal = "ghostty",
        browser = "helium",
        editor = "zeditor",
        file = "nautilus",
    },
    monitor = {
        monitors = {
            {
                output = "",
                mode = "preferred",
                position = "auto",
                scale = "1",
            },
        },
    }
}

local has_nixvars, nixvars = pcall(require, "nixvars")
if not has_nixvars or type(nixvars) ~= "table" then
    nixvars = {}
end

VARS = nixvars
VARS.programs = VARS.programs or {}
for name, value in pairs(defaults.programs) do
    if VARS.programs[name] == nil then
        VARS.programs[name] = value
    end
end

VARS.monitor = VARS.monitor or {}
VARS.monitor.monitors = VARS.monitor.monitors or defaults.monitor.monitors

for _, monitor in ipairs(VARS.monitor.monitors) do
    hl.monitor(monitor)
end

hl.workspace_rule {
    workspace = "1",
    default = true,
    persistent = true,
    monitor = VARS.monitor.primary
}

for i = 2, 9 do
    hl.workspace_rule {
        workspace = tostring(i),
        monitor = VARS.monitor.primary
    }
end

hl.config {
    input = {
        kb_layout = "us",
        kb_variant = "altgr-intl",
        follow_mouse = 1,

        ["touchpad.natural_scroll"] = true,

        sensitivity = 0,
        force_no_accel = true,
        numlock_by_default = true,
    }
}

hl.config {
    decoration = {
        rounding = 10,
        ["shadow.enabled"] = false,
        blur = {
            enabled = true
        },
        dim_special = 0.3
    },
    animations = {
        enabled = false,
    }
}

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

hl.config {
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 0,
        layout = "master",
    }
}

require("windowrules")
require("keybinds")
