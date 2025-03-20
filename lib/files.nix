{lib, ...}: let
  inherit
    (lib)
    pipe
    mapAttrsToList
    filterAttrs
    hasSuffix
    hasPrefix
    flatten
    nameValuePair
    removeSuffix
    ;
  inherit
    (builtins)
    readDir
    pathExists
    listToAttrs
    unsafeDiscardStringContext
    ;
in rec {
  # a single 'module' can be:
  # a .nix file on the base dir
  # .nix files on a directory
  # a directory with a default.nix file (imported as a dir)
  walkModules = dir:
    pipe dir [
      readDir
      (filterAttrs (name: type: type == "directory" || type == "regular")) # ignore symlinks and other funky things
      (filterAttrs (name: type: type == "directory" || hasSuffix ".nix" name)) # ignore non-nix files
      # (filterAttrs (name: type: type == "directory" || hasPrefix "_" name)) # ignore files starting with underscore
      (filterAttrs (name: _: name != "default.nix" && name != "flake.nix"))
      (mapAttrsToList (
        name: type:
          if type == "directory" && pathExists "${dir}/${name}/default.nix"
          then "${dir}/${name}"
          else if type == "directory"
          then walkModules "${dir}/${name}"
          else "${dir}/${name}"
      ))
      flatten
    ];

  mapModules = predicate: dir: map predicate (walkModules dir);

  getHosts = dir: let
    # the gist: nix strings have contexts to make concatenation more efficient on derivations
    # you can't use strings with contexts as attribute keys, so we need to discard the context part.
    baseName = path: unsafeDiscardStringContext (removeSuffix ".nix" (baseNameOf path));
    genHost = path: nameValuePair (baseName path) (import path);
  in
    listToAttrs (map genHost (walkModules dir));
}
