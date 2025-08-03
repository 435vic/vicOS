{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-wsl,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (prev: final: {
          unstable = final;
        })
      ];
    };

    vicosCats = import ../../nixcats-nvim inputs.nixCats;
    nixCat = vicosCats.builder nixpkgs system vicosCats.default;
    nvimPackages = let
      inherit (nixCat.utils) mergeCatDefs;
      impureOverride = {...}: {settings.wrapRc = false;};
      mkCat = name: def:
        (nixCat.override {inherit name;})
        // {
          impure = nixCat.override {
            inherit name;
            packageDefinitions.${name} = mergeCatDefs nixCat.packageDefinitions.${name} impureOverride;
          };
        };
    in
      pkgs.lib.mapAttrs mkCat nixCat.packageDefinitions;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.default
          {
            system.stateVersion = "25.05";
            nixpkgs.pkgs = pkgs;
            wsl.enable = true;
            wsl.defaultUser = "vico";
            vicos.username = "vico";
            vicos.flake = let
              vicosPath = "/home/vico/vicOS";
              rev = toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
            in {
              inherit rev;
              lib = import ../../lib {inherit (nixpkgs) lib;};
              path = vicosPath;
              packages = nvimPackages;
            };
          }
          ./configuration.nix
          ../../modules/minimal.nix
        ];
      };
    };
  };
}
