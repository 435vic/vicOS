{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.hardware.audio;
in {
  options.vicos.hardware.audio.enable = mkEnableOption "audio";

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    security.rtkit.enable = true;
    vicos.user.extraGroups = ["audio"];

    vicos.user.packages = with pkgs; [
      alsa-utils
      pavucontrol
      pulseaudio
    ];

    hardware.pulseaudio.enable = mkForce false;
  };
}
