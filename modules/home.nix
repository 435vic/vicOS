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
    # Symlink Join can't be used here as it cannot access /home during derivations
    # we need to pass the tree structure manually
    lib.vicos.dirFromConfig = path: let
      # returns a list of paths in a folder with names relative to said folder
      walkDir = base: dir: let
        filterOutSymlinks = filterAttrs (_: type: type == "directory" || type == "regular");
        fullPath = if dir == "" then base else "${base}/${dir}";
      in pipe fullPath [
        builtins.readDir
        filterOutSymlinks
        (mapAttrsToList (name: type:
          let
            relPath = if dir == "" then name else "${dir}/${name}";
          in
            if type == "directory"
            then walkDir base relPath
            else relPath
        ))
        flatten
      ];

      commandArgs = {
        paths = walkDir "${config.vicos.flake.path}/config/${path}" "";
        passAsFile = [ "paths" ];
      };
    in pkgs.runCommandLocal (baseNameOf path) commandArgs ''
      mkdir -p $out
      for path in $(cat $pathsPath); do
        ln -s ${config.vicos.flake.path}/config/${path}/$path $out/$path
      done
    '';

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