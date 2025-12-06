{ lib, vicos, config, ... }:
{
  imports = [
    ./base.nix
    ../desktop/desktop.nix
    ../desktop/gaming.nix
    ../desktop/launcher.nix
    ../desktop/hyprland.nix
    ../shell/shell.nix
    ../shell/tmux.nix
    ../shell/fish.nix
    ../desktop/fonts.nix
  ];

  boot = {
    plymouth.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    consoleLogLevel = 3;
    initrd.verbose = false;
    loader.timeout = 0;
  };

  # add the full neovim experience
  environment.systemPackages = [
    vicos.packages.vvim-unfree.impure
  ];

  home.configFile."nvim" = {
    source = config.lib.vicos.stash "config/nvim";
    recursive = true;
  };

  programs.nix-ld.enable = lib.mkDefault true;

  # I prefer iwd for wireless
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };
}
