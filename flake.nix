{
  description = "vico's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/2ef974182ef62a6a6992118f0beb54dce812ae9b";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    alacritty-theme.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;
          # Configure the global instance of pkgs
          #_module.args.pkgs = import nixpkgs {
          #  inherit system;
          #  # Overlays would go here (or an import)
          #  overlays = [
          #    alacritty-theme.overlays.default
          #  ];
          #  config.allowUnfree = true;
          #};
        };

      flake.nixosConfigurations = {
        thunkbox = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
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
