{ lib, ... }:
{
  imports = [
    ./cli.nix
    ./desktop.nix
    ./fish.nix
    ./git.nix
    ./prompt.nix
    ./rbw.nix
    ./tmux.nix
  ];

  options.vicos = {
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Existing normal user receiving the personal environment. Fleet policy owns the account.";
    };

    dotfilesPath = lib.mkOption {
      type = lib.types.str;
      default = "vicOS";
      description = ''
        Path to the mutable dotfiles checkout, absolute or relative to the user's
        home directory.
      '';
    };
  };
}
