# WSL profile - shell environment without desktop components
#
# This profile provides a complete CLI environment for WSL, including
# shell configuration, neovim, and common CLI tools.
{
  lib,
  pkgs,
  config,
  vicos,
  ...
}:
{
  imports = [
    ./base.nix # includes vicos.nix and stash.nix
    ../shell/shell.nix
    ../shell/fish.nix
    ../shell/tmux.nix
  ];

  config = {
    # Full neovim
    environment.systemPackages = [
      vicos.packages.vvim.impure

      # WSL utilities
      pkgs.wslu # wslview, wslpath, etc.
    ];

    home.configFile."nvim" = {
      source = config.lib.vicos.stash "config/nvim";
      recursive = true;
    };

    networking.useNetworkd = false;

    # Use Windows browser via wslview
    environment.sessionVariables = {
      BROWSER = "wslview";
    };

    # WSL-specific configuration
    wsl = {
      enable = true;
      defaultUser = config.vicos.user;
      # Use Windows OpenGL for GUI apps
      useWindowsDriver = true;
    };
  };
}
