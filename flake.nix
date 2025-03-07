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
  } @ inputs: let
    allLinuxSystems = [ "x86_64-linux" "aarch64-linux" ];
    allDarwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
    allSystems = allLinuxSystems ++ allDarwinSystems;
    forAllSystems = nixpkgs.lib.genAttrs allSystems;

    pkgsConfig = {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [];
    };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

  };
}
