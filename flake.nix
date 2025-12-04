{
  description = "vico's dotfiles - Neovim, packages, shells, and templates";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stash.url = "github:435vic/stash";
    stash.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    let
      vicosCats = import ./nixcats-nvim inputs.nixCats;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.alejandra;

          packages =
            (import ./packages pkgs)
            // (vicosCats.mkNvimPackages {
              inherit system;
              nixpkgs = nixpkgs;
            });

          devShells = {
            java = import ./shells/java.nix { inherit pkgs; };
          };
        };

      flake =
        { config, ... }:
        {
          nixosConfigurations.test = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              self.nixosModules.full
              {
                vicos.user = "test";
                boot.loader.grub.devices = [ "nodev" ];
                fileSystems."/" = {
                  device = "/dev/sda1";
                  fsType = "ext4";
                };
                nixpkgs.config.allowUnfree = true;
                system.stateVersion = "24.11";
              }
            ];
          };

          templates = {
            rust = {
              path = ./templates/rust;
              description = "Rust flake template using fenix";
            };
          };

          nixosModules =
            let
              mkVicOSModule =
                mod:
                { pkgs, ... }:
                let
                  system = pkgs.stdenv.hostPlatform.system;
                in
                {
                  imports = [
                    mod
                    inputs.stash.nixosModules.stash
                  ];

                  _module.args.vicos = {
                    packages = self.packages.${system};
                  };
                };
            in
            rec {
              full = mkVicOSModule ./modules/profiles/nonserver.nix;
              server = mkVicOSModule ./modules/profiles/server.nix;
              default = full;
            };
        };
    };
}
