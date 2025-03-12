{ lib }:
let
  inherit (lib) pipe mapAttrsToList filterAttrs hasSuffix flatten;
  inherit (builtins) readDir pathExists;
in rec {
  # a single 'module' can be:
  # a .nix file on the base dir
  # .nix files on a directory
  # a directory with a default.nix file (imported as a dir)
  walkModules = dir: pipe dir [
    readDir
    (filterAttrs (name: type: type == "directory" || type == "regular")) # ignore symlinks and other funky things
    (filterAttrs (name: type: type == "directory" || hasSuffix ".nix" name)) # ignore non-nix files
    (filterAttrs (name: _: name != "default.nix" && name != "flake.nix"))
    (mapAttrsToList (name: type:
      if type == "directory" && pathExists "${dir}/${name}/default.nix"
      then "${dir}/${name}"
      else if type == "directory"
      then walkModules "${dir}/${name}"
      else "${dir}/${name}"
    ))
    flatten
  ];

  mapModules = predicate: dir: map predicate (walkModules dir);
}