{
  lib,
  config,
  ...
}: let
  cfg = config.vicos.services.syncthing;
in {
  config = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "vico";
      settings = {
        devices = {
          "vico_phone" = "LRQUHKH-METM6P4-27SJ4QD-OMWQXDM-YDWIYRL-NLJTD6I-LFHTMLK-TNXFTAC";
        };

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
