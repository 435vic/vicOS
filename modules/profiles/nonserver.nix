{
  lib,
  pkgs,
  vicos,
  config,
  ...
}:
{
  imports = [
    ./base.nix
    ./nixos.nix
    ../desktop/desktop.nix
    ../desktop/gaming.nix
    ../desktop/launcher.nix
    ../desktop/hyprland.nix
    ../desktop/xdg.nix
    ../desktop/music.nix
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
    vicos.packages.vvim.impure
  ];

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "vicos-hid-udev-rules";
      destination = "/lib/udev/rules.d/60-vicos-hid.rules";
      text = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="4b42", ATTRS{idProduct}=="6061", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d060", TAG+="uaccess"
      '';
    })
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
      General = {
        Country = "MX";
      };
      Network = {
        EnableIPv6 = true;
      };
      Settings = {
        AutoConnect = true;
      };
    };
  };
}
