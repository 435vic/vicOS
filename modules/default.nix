# This file imports all modules on this folder.
{ lib, config, options, ... }:
with lib;
let
  inherit (config.vicos.flake.lib) mapModules;
  cfg = config.vicos;
  readOnly = types.unique { message = "This option is read-only."; };
in
{
  imports = mapModules import ./.;

  options.vicos.user = mkOption {
    type = types.attrs;
    description = "The main user account.";
    default = { name = ""; };
  };

  options.vicos.flake = {
    path = mkOption {
      type = types.str;
      default = "/home/vico/vicOS";
      description = "Path to the vicOS flake.";
      example = "/home/user/.config/vicOS";
    };

    modules = mkOption {
      type = with types; readOnly (attrsOf unspecified);
      default = {};
      description = "modules provided by vicOS flake inputs";
    };

    lib = mkOption {
      type = with types; readOnly (attrsOf unspecified);
      default = {};
      description = "vicOS library functions accessible to modules";
    };

    system = mkOption {
      type = with types; readOnly str;
      description = "The host's current system.";
    };
  };

  assertions = [
    {
      assertion = isPathDirectory cfg.path;
      message = "${cfg.path} must be a directory.";
    }
    {
      assertion = pathExists (cfg.path + "/flake.nix");
      message = "${cfg.path}/flake.nix is not a flake. Are you sure you're using the correct path?";
    }
    {
      assertion = cfg.user.name != "";
      message = "User name must be set.";
    }
  ];

  config = {
    vicos.user = {
      description = mkDefault "The primary user account";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      home = "/home/${cfg.user.name}";
      group = "users";
      uid = 1000;
    };

    system.stateVersion = "23.11";

    environment.sessionVariables = mkOrder 10 {
      DOTFILES_HOME = cfg.flake.path;
      NIXPKGS_ALLOW_UNFREE = "1"; # sorry I don't care :p
    };

    users.users.${cfg.user.name} = mkAliasDefinitions options.vicos.user;
  };
}