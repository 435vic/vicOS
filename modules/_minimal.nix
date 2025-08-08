{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib; let
  inherit (config.vicos) flake;
  cfg = config.vicos;
  readOnly = types.unique {message = "This option is read-only.";};
in {
  imports = [
    ./home.nix
    ./shell/git.nix
    ./shell/tmux.nix
    ./shell/shell.nix
    ./dev/nvim.nix
    ./dev/nix.nix
  ];

  options.vicos = {
    username = mkOption {
      type = types.str;
      example = "vico";
      description = "The username for the main user account.";
    };

    user.packages = mkOption {
      type = with types; listOf package;
      default = [];
    };

    user.home = mkOption {
      type = types.str;
      default = "/home/vico";
    };

    flake = {
      path = mkOption {
        type = types.str;
        default = "/home/vico/vicOS";
        description = "Path to the vicOS flake.";
        example = "/home/user/.config/vicOS";
      };

      inputs = mkOption {
        type = with types; readOnly (attrsOf unspecified);
        default = {};
        description = "vicOS flake inputs";
      };

      packages = mkOption {
        type = with types; readOnly (attrsOf package);
        default = {};
        description = "vicOS packages";
      };

      lib = mkOption {
        type = with types; readOnly (attrsOf unspecified);
        default = {};
        description = "vicOS library functions accessible to modules";
      };

      rev = mkOption {
        type = with types; readOnly str;
        description = "vicOS configuration revision";
      };
    };
  };

  config = {
    nix = {
      extraOptions = ''
        warn-dirty = false
        experimental-features = nix-command flakes ca-derivations
      '';

      settings = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];

        auto-optimise-store = true;
        trusted-users = [
          "root"
          "vico"
        ];
        allowed-users = [
          "root"
          "vico"
        ];
      };
    };

    environment.systemPackages = cfg.user.packages;
  };
}
