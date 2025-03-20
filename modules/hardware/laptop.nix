{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.hardware.laptop;
in {
  options = {
    vicos.hardware.laptop = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the system is a laptop";
      };
      quietBoot = mkEnableOption "Quiet Boot";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        brightnessctl
        acpi
      ];

      boot.plymouth.enable = true;
    }
    (mkIf cfg.quietBoot {
      boot = {
        kernelParams = [
          "quiet"
          "splash"
          "udev.log_level=3"
        ];
        consoleLogLevel = 0;
        initrd.verbose = false;
      };
    })
  ]);
}
