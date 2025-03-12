{
  description = "vicOS v2 - Now with added protein!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs:
  let
    inherit (nixpkgs.lib) genAttrs;
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
      lib = import ./lib { inherit (nixpkgs) lib; };
      path = vicosPath;
    };

    pkgsDefaults = {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [];
    };

    mkHost = import ./lib/hosts.nix { inherit pkgsDefaults vicos; };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

  };
}
