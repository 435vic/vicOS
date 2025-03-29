{
  config,
  options,
  pkgs,
  lib,
  ...
}:
with lib; let
  mkStringOpt = default: description: mkOption {
    type = types.str;
    inherit default description;
  };
  homeDir = config.vicos.user.home;
  cfg = config.home;
in {
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

    binDir     = mkStringOpt "${homeDir}/.local/bin" "";
    cacheDir   = mkStringOpt "${homeDir}/.cache" "";
    configDir  = mkStringOpt "${homeDir}/.config" "";
    dataDir    = mkStringOpt "${homeDir}/.local/share" "";
    stateDir   = mkStringOpt "${homeDir}/.local/state" "";
    fakeDir    = mkStringOpt "${homeDir}/.local/user" "";
  };

  config = let
    checkPath = path:
      if pathExists path
      then path
      else abort "Error adding flake file/dir: ${path} does not exist.";
    inherit (config.home-manager.users.${config.vicos.username}.lib.file) mkOutOfStoreSymlink;
  in {
    # config.lib is defined by home-manager as an attrset

    # these functions allow symlinking to the actual flake path
    # and not a store path, allowing quick edits without rebuilding
    lib.vicos.fileFromFlake = path: mkOutOfStoreSymlink (checkPath "${config.vicos.flake.path}/${path}");
    lib.vicos.fileFromConfig = path: mkOutOfStoreSymlink (checkPath "${config.vicos.flake.path}/config/${path}");
    # This function will recursively generate symlinks for a folder in config/
    # Works like home.file.<filename>.recursive but the symlinks point outside the store path
    lib.vicos.dirFromConfig = path: let
      # returns a list of paths in a folder with names relative to said folder
      walkDir = base: dir: let
        filterOutSymlinks = filterAttrs (_: type: type == "directory" || type == "regular");
        fullPath =
          if dir == ""
          then base
          else "${base}/${dir}";
      in
        pipe fullPath [
          builtins.readDir
          filterOutSymlinks
          (mapAttrsToList (
            name: type: let
              relPath =
                if dir == ""
                then name
                else "${dir}/${name}";
            in
              if type == "directory"
              then walkDir base relPath
              else relPath
          ))
          flatten
        ];

      commandArgs = {
        paths = walkDir "${config.vicos.flake.path}/config/${path}" "";
        passAsFile = ["paths"];
      };
    in
      pkgs.runCommandLocal (baseNameOf path) commandArgs ''
        mkdir -p $out
        for path in $(cat $pathsPath); do
          mkdir -p $out/$(dirname $path)
          ln -s ${config.vicos.flake.path}/config/${path}/$path $out/$path
        done
      '';

    environment.sessionVariables = mkOrder 10 {
      XDG_BIN_HOME    = cfg.binDir;
      XDG_CACHE_HOME  = cfg.cacheDir;
      XDG_CONFIG_HOME = cfg.configDir;
      XDG_DATA_HOME   = cfg.dataDir;
      XDG_STATE_HOME  = cfg.stateDir;
      XDG_FAKE_HOME = cfg.fakeDir;
      XDG_DESKTOP_DIR = cfg.fakeDir;
    };

    home-manager = {
      useUserPackages = true;
      backupFileExtension = "hm-backup";
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
