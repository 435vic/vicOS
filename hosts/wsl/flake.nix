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
    nvimPackages = vicosCats.mkNvimPackages { inherit nixpkgs system;  };
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
            nix.registry.vicos = {
              from.id = "vicOS";
              from.type = "indirect";
              to = {
                type = "git";
                submodules = true;
                dir = "hosts/wsl";
                url = "file:///home/vico/vicOS";
              };
            };
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
          ../../modules/_minimal.nix
        ];
      };
    };

    packages.${system} = nvimPackages;
  };
}
