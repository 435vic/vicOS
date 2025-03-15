{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib;
{
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

  config = let
    checkPath = path: if pathExists path then path else abort "Error adding flake file/dir: ${path} does not exist.";
    inherit (config.home-manager.users.${config.vicos.username}.lib.file) mkOutOfStoreSymlink;
  in {
    # config.lib is defined by home-manager as an attrset

    # these functions allow symlinking to the actual flake path
    # and not a store path, allowing quick edits without rebuilding
    lib.vicos.fileFromFlake = path: mkOutOfStoreSymlink (checkPath "${config.vicos.flake.path}/${path}");
    lib.vicos.fileFromConfig = path: mkOutOfStoreSymlink (checkPath "${config.vicos.flake.path}/config/${path}");
    lib.vicos.dirFromConfig = path: pkgs.symlinkJoin { name = baseNameOf path; paths = [ (checkPath "${config.vicos.flake.path}/config/${path}") ]; };

    home-manager = {
      useUserPackages = true;

      users.${config.vicos.username} = {
        home.stateVersion = config.system.stateVersion;

        xdg = {
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile = mkAliasDefinitions options.home.dataFile;
        };
      };
    };
  };
}