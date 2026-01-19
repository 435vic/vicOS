{
  pkgs,
  lib,
  config,
  vicos ? { },
  ...
}:
let
  cfg = config.vicos.desktop;
in
{
  options.vicos.desktop = {
    wayland.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable wayland programs and tools";
      default = false;
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
          libnotify
          xdg-utils
          playerctl
          adwaita-qt
          ripdrag
          mako # notification daemon
          pamixer # volume control
          brightnessctl # backlight control
          btop # process manager
          ghostty # terminal
          legcord # discord client
          thunderbird # mail client
          mpv # video player
          ;

        helium = lib.mkIf (vicos ? packages) vicos.packages.helium;
      };

      programs.localsend.enable = true;

      # DARK MODEEEE
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
              };
            };
          }
        ];
      };
    }
    (lib.mkIf cfg.wayland.enable {
      environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
          wev
          wl-clipboard
          swappy
          swayimg
          imv
          ;
      };
    })
  ];
}
