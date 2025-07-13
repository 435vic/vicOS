{
  lib,
  config,
  ...
}: with lib; let
  cfg = config.vicos.services.syncthing;
in {
  options.vicos.services.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/vico";
      user = "vico";
      settings = {
        folders = {
          "Obsidian" = {
            path = "~/vaults";
            devices = [ "vico_phone" ];
          };

          "Sync" = {
            path = "~/sync";
            devices = [ "vico_phone" ];
          };

          "Music" = {
            path = "~/music";
          };
          
          # phone pics
          "Camera" = {
            path = "~/camera";
            devices = [ "vico_phone" ];
          };
        };
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
