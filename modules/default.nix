/*
  *
  * default.nix - module entry point
  * this module provides some options provided by the flake,
  * as well as defining some sensible defaults for any system.
  *
*/
{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;
let
  inherit (config.vicos) flake;
  cfg = config.vicos;
  readOnly = types.unique { message = "This option is read-only."; };
  walkModules = (import ../lib { inherit lib; }).walkModules;
in
{
  imports = walkModules ./.;

  options.vicos = {
    user = mkOption {
      type = with types; attrsOf unspecified;
      description = "The main user account.";
    };

    username = mkOption {
      type = types.str;
      example = "vico";
      description = "The username for the main user account.";
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
        default = { };
        description = "vicOS flake inputs";
      };

      lib = mkOption {
        type = with types; readOnly (attrsOf unspecified);
        default = { };
        description = "vicOS library functions accessible to modules";
      };

      rev = mkOption {
        type = with types; readOnly str;
        description = "vicOS configuration revision";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = pathIsDirectory cfg.flake.path;
        message = "${cfg.flake.path} must be a directory.";
      }
      {
        assertion = pathExists (cfg.flake.path + "/flake.nix");
        message = "${cfg.flake.path}/flake.nix is not a flake. Are you sure you're using the correct path?";
      }
    ];

    lib.flake.getInput =
      input: output: element:
      let
        inherit (config.nixpkgs.hostPlatform) system;
        inputs = cfg.flake.inputs;
      in
      {
        overlays = inputs.${input}.overlays.${element};
        packages = inputs.${input}.packages.${system}.${element};
      }
      .${output};

    i18n.defaultLocale = mkDefault "en_US.UTF-8";

    vicos.user = {
      description = mkDefault "The primary user account";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      home = "/home/${cfg.username}";
      name = cfg.username;
      group = "users";
      uid = 1000;
    };
    users.users.${cfg.username} = mkAliasDefinitions options.vicos.user;

    # allows us to use nixpkgs-unstable on nix path and registry
    nixpkgs.flake.setNixPath = false;
    nixpkgs.flake.setFlakeRegistry = false;

    nix = {
      extraOptions = ''
        warn-dirty = false
        experimental-features = nix-command flakes ca-derivations
      '';

      nixPath = [
        "nixpkgs=${flake.inputs.nixpkgs-unstable}"
        "dotfiles=${flake.path}"
      ];

      # SIX FEET UNDER PLEASE
      channel.enable = false;

      registry.nixpkgs.flake = flake.inputs.nixpkgs-unstable;
      registry.nixpkgs-stable.flake = flake.inputs.nixpkgs;
      registry.vicos = {
        from.id = "vicOS";
        from.type = "indirect";
        to.path = "${cfg.flake.path}";
        to.type = "path";
      };

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
          cfg.user.name
        ];
        allowed-users = [
          "root"
          cfg.user.name
        ];
      };
    };

    virtualisation.vmVariant.virtualisation = {
      memorySize = 2048; # default: 1024
      cores = 2; # default: 1
    };

    # change later!
    vicos.user.initialPassword = "nixos";
    users.users.root.initialPassword = "nixos";

    hardware.enableRedistributableFirmware = true;

    boot = {
      # Prefer the latest kernel
      kernelPackages = mkDefault pkgs.unstable.linuxPackages_latest;
      loader = {
        efi.canTouchEfiVariables = mkDefault true;
        systemd-boot.enable = mkDefault true;
        systemd-boot.configurationLimit = mkDefault 10;
      };
    };

    system.stateVersion = "23.11";

    environment.sessionVariables = mkOrder 10 {
      DOTFILES_HOME = cfg.flake.path;
      NIXPKGS_ALLOW_UNFREE = mkDefault "1"; # sorry I don't care :p
    };
  };
}
