{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.desktop.hyprland;
in
{
  options.vicos.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland";
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration to add to the Hyprland configuration file.";
    };

    defaultEditor = mkOption {
      type = types.str;
      default = "zeditor";
      description = "Default editor to launch when inputting editor keybind.";
    };

    defaultBrowser = mkOption {
      type = types.str;
      default = if config.vicos.desktop.browser.zen.enable then "zen" else "firefox";
      description = "Default browser to launch when inputting browser keybind.";
    };

    defaultTerminal = mkOption {
      type = types.str;
      default = "alacritty";
      description = "Default terminal to launch when inputting terminal keybind.";
    };
  };

  config = mkIf cfg.enable {
    vicos.desktop.wayland.enable = true;

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # the newer versions of hyprland require recent mesa drivers
    hardware.graphics = {
      enable = true;
      enable32Bit = true; 
      #package = pkgs.unstable.mesa.drivers;
      #package32 = pkgs.unstable.pkgsi686Linux.mesa.drivers;
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      #package = pkgs.unstable.hyprland;
      #portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };

    environment.systemPackages = with pkgs.unstable; [
      hyprlock # lock screem
      hyprpaper # wallpaper manager
      hyprpicker # color picker
      hyprshot # screenshot tool

      mako # notification daemon
      pamixer # volume control
    ];

    systemd.user.targets.hyprland-session = {
      unitConfig = {
        Description = "Hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "Hyprland";
        user = config.vicos.username;
      };
    };

    home.configFile = {
      hypr = {
        source = config.lib.vicos.dirFromConfig "hypr";
        recursive = true;
      };

      "hypr/hyprland.pre.conf".text = ''
        $term = ${cfg.defaultTerminal}
        $browser = ${cfg.defaultBrowser}
        $editor = ${cfg.defaultEditor}
      '';

      "hypr/hyprland.post.conf".text = cfg.extraConfig;
    };
  };
}
