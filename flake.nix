{
  description = "vico's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    g14-kernel.url = "gitlab:asus-linux/fedora-kernel/rog-6.11";
    g14-kernel.flake = false;
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-parts,
      nixos-hardware,
      alacritty-theme,
      ...
    }:
    let
      inherit (self) outputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          packages = import ./packages pkgs;
        };

      flake.overlays = {
        localpkgs = final: _prev: {
          local = import ./packages final.pkgs;
        };
      };

      flake.templates = {
        rust = {
          path = ./templates/rust;
          description = "A basic flake for rust development using direnv and fenix";
        };

        nodejs_22 = {
          path = ./templates/node;
          description = "Node.js development with pnpm";
        };

        c-cpp = {
          path = ./templates/c-cpp;
          description = "C/C++ development";
        };
      };

      flake.nixosConfigurations = {
        thunkbox = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
            system = "x86_64-linux";
          };
          modules = [
            nixos-hardware.nixosModules.asus-zephyrus-ga503
            ./thunkbox
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };

              home-manager.users.vico = {
                imports = [
                  ./home.nix
                  inputs.nixvim.homeManagerModules.nixvim
                ];
              };
            }
          ];
        };
      };
    };
}
