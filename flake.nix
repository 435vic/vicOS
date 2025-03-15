{
  description = "vicOS v2 - Now with added protein!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs:
  let
    inherit (nixpkgs.lib) genAttrs mapAttrs;
    inherit (builtins) getEnv;

    allLinuxSystems = [ "x86_64-linux" "aarch64-linux" ];
    allDarwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
    allSystems = allLinuxSystems ++ allDarwinSystems;
    forAllSystems = genAttrs allSystems;

    vicos = let
      pathEnv = getEnv "VICOS_PATH";
      vicosPath = (
        if pathEnv == ""
        then abort "VICOS_PATH must be set!"
        else pathEnv
      );
    in {
      inherit inputs;
      lib = import ./lib/module { inherit (nixpkgs) lib; };
      path = vicosPath;
    };

    pkgsDefaults = {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [];
    };

    hostLib = import ./lib/hosts.nix { inherit pkgsDefaults vicos; };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

    packages = forAllSystems (system: let
      basePath = "/home/vico/vicOS/config";
      dirFromConfig = with nixpkgs.lib; path: let
        walkDir = base: dir: let
          filterOutSymlinks = filterAttrs (_: type: type == "directory" || type == "regular");
          fullPath = if dir == "" then base else "${base}/${dir}";
        in pipe (builtins.readDir fullPath) [
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
          paths = walkDir "${basePath}/${path}" "";
          passAsFile = [ "paths" ];
        };
      in nixpkgs.legacyPackages.${system}.runCommandLocal (baseNameOf path) commandArgs ''
        mkdir -p $out
        for path in $(cat $pathsPath); do
          ln -s ${basePath}/${path}/$path $out/$path
        done
      '';
    in {
      testRecSymlink = dirFromConfig "hypr";
    });

    nixosConfigurations =
    let
      # why specify the name of the host both as the dir/filename and in the config
      # when you can spend more time writing a function to do it for you?
      mkNamedHost = name: config: hostLib.mkHost (config // { inherit name; });
      # hosts are provided the vicOS object with inputs, context, etc.
      callHost = name: host: mkNamedHost name (host vicos);
    in
      mapAttrs callHost (vicos.lib.getHosts ./hosts);

    lib = vicos.lib;
  };
}
