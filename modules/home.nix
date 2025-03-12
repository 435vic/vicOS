{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.home;
  flake-modules = config.vicos.flake.modules;
in {
  imports = [
    flake-modules.home-manager.home-manager
  ];

  options.home = {
    configFile = mkOption {
      type = types.attrs;
      default = {};
      description = "Files to place in $XDG_CONFIG_HOME";
    };

    dataFile = mkOption {
      type = types.attrs;
      default = {};
      description = "Files to place in $XDG_DATA_HOME";
    };
  };

  config = {
    # config.lib is defined by home-manager as an attrset

    # these functions allow symlinking to the actual flake path
    # and not a store path, allowing quick edits without rebuilding
    lib.vicos.fromFlake = path: config.lib.file.mkOutOfStoreSymlink "${config.vicos.flake.path}/${path}";
    lib.vicos.fromConfig = path: config.lib.file.mkOutOfStoreSymlink "${config.vicos.flake.path}/config/${path}";

    home-manager = {
      useUserPackages = true;

      users.${config.vicos.user.name} = {
        home.stateVersion = config.system.stateVersion;

        xdg = {
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile = mkAliasDefinitions options.home.dataFile;
        };
      };
    };
  };
}