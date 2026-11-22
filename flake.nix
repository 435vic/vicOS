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
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          rbw = pkgs.callPackage ./packages/rbw { };
          neovim = pkgs.callPackage ./packages/neovim { inherit nixCats; };
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          helium = pkgs.callPackage ./packages/helium { enableWideVine = true; };
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
              nixpkgs.config.allowUnfree = true;
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

      # Rewrites pins of packages that track upstream releases outside nixpkgs.
      # Run from the checkout: `nix run .#update [-- nix-update flags]`. Review
      # the diff yourself; nothing is committed.
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # 1.16 cannot evaluate a dirty local flake on Nix 2.35 (Mic92/nix-update#693).
          nix-update =
            if nixpkgs.lib.versionAtLeast pkgs.nix-update.version "1.17.0" then
              pkgs.nix-update
            else
              pkgs.nix-update.overridePythonAttrs (old: rec {
                version = "1.17.0";
                src = pkgs.fetchFromGitHub {
                  owner = "Mic92";
                  repo = "nix-update";
                  tag = "v${version}";
                  hash = "sha256-TCOhUWb53V3nrJRD3JuADly1U9fNi0Z79QMcjhbefHg=";
                };
                build-system = [ pkgs.python3Packages.hatchling ];
                dependencies = (old.dependencies or [ ]) ++ [ pkgs.python3Packages.ast-grep-py ];
              });
          update = pkgs.writeShellApplication {
            name = "vicos-update";
            runtimeInputs = [ nix-update ];
            text = ''
              if [ ! -f packages/helium/default.nix ]; then
                echo "run this from the root of the vicOS checkout" >&2
                exit 1
              fi
              nix-update --flake helium "$@"
            '';
          };
        in
        {
          update = {
            type = "app";
            program = nixpkgs.lib.getExe update;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
