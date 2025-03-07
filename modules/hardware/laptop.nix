{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  hardware = config.vicos.hardware;
in {
  options = {
    config.hardware.isLaptop = mkOption {
      type = types.bool;
      default = false;
      description = "Whether the system is a laptop";
    };

    config.vicos.hardware.laptop = {
      quietBoot = mkEnableOption "Quiet Boot";
    };
  };

  config = mkMerge [
    {
      environment.systemPackages = with pkgs; [
        brightnessctl
        acpi
      ];

      boot.plymouth.enable = true;
    }
    (mkIf hardware.laptop.quietBoot {
      kernelParams = [
        "quiet"
        "splash"
        "udev.log_level=3"
      ];
      consoleLogLevel = 0;
      initrd.verbose = false;
    })
  ];
}