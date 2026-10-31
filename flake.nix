{
  description = "vicOS personal environment — incremental foundation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    stash.url = "github:435vic/stash";
    stash.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixCats,
      stash,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      module = {
        imports = [
          stash.nixosModules.default
          ./modules
        ];
        _module.args.nixCats = nixCats;
      };
    in
    {
      # TODO(viclan): declare the normal vicos.user and select CLI/desktop/rbw capabilities.
      # Own login shells (desktop Fish; server Bash + interactive Fish handoff),
      # Git identity, SSH keys/rules, and rbw.email/url; follow the fleet nixpkgs.
      # Provision vicos.dotfilesPath or configure stashes.vicos.init for rewrite;
      # migrate home.file/home.configFile to stash.users.<user>.files.
      nixosModules.default = module;

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          rbw = pkgs.callPackage ./packages/rbw { };
          neovim = pkgs.callPackage ./packages/neovim { inherit nixCats; };
        }
      );

      nixosConfigurations = forAllSystems (
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            module
            {
              boot.isContainer = true;
              system.stateVersion = "26.05";
              users.users.test.isNormalUser = true;
              vicos.user = "test";
              vicos.desktop.enable = true;
              vicos.rbw = {
                enable = true;
                email = "test@example.invalid";
              };
            }
          ];
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
