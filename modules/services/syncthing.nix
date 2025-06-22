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
        devices = {
          "vico_phone" = {
            id = "LRQUHKH-METM6P4-27SJ4QD-OMWQXDM-YDWIYRL-NLJTD6I-LFHTMLK-TNXFTAC";
          };
        };

        # present in every host
        folders = {
          "Obsidian" = {
            path = "~/vaults";
            devices = [ "vico_phone" ];
          };

          "Sync" = {
            path = "~/sync";
            devices = [ "vico_phone" ];
          };
        };
      };
    };

    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
