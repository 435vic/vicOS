# WSL profile - shell environment without desktop components
#
# This profile provides a complete CLI environment for WSL, including
# shell configuration, neovim, and common CLI tools.
#
# NOTE: This profile includes a bandaid fix for stash, which normally
# relies on systemd for symlinking config files. Since WSL typically
# runs without systemd, we manually symlink stash-based configs during
# system activation. This should be removed once stash supports
# activation-time linking.
{
  lib,
  pkgs,
  config,
  vicos,
  ...
}:
let
  user = config.vicos.user;
  homeDir = config.users.users.${user}.home;
  userStash = config.stash.users.${user};

  # Get all enabled files from stash config
  enabledFiles = lib.filterAttrs (_: f: f.enable) userStash.files;

  # Stash-based files (not static, need runtime symlinking)
  stashFiles = lib.filterAttrs (_: f: !f.source.static) enabledFiles;

  # Static files (from nix store, also need symlinking for WSL)
  staticFiles = lib.filterAttrs (_: f: f.source.static) enabledFiles;

  # Get the stash path for a given stash name
  getStashPath = stashName: userStash.stashes.${stashName}.path;

  # Generate symlink commands for stash-based files
  stashFileLinks = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: value:
      let
        stashPath = getStashPath value.source.stash;
        target = "${homeDir}/${value.target}";
        source = "${stashPath}/${value.source.path}";
      in
      ''
        mkdir -p "$(dirname "${target}")"
        [ -L "${target}" ] && rm "${target}"
        [ -e "${target}" ] && echo "  WARNING: ${target} exists and is not a symlink, skipping" && continue
        ln -sfT "${source}" "${target}"
        echo "  ${value.target} -> ${value.source.stash}:${value.source.path}"
      ''
    ) stashFiles
  );

  # Generate symlink commands for static files (from nix store)
  staticFileLinks = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: value:
      let
        target = "${homeDir}/${value.target}";
        source = toString value.source.path;
      in
      ''
        mkdir -p "$(dirname "${target}")"
        [ -L "${target}" ] && rm "${target}"
        [ -e "${target}" ] && echo "  WARNING: ${target} exists and is not a symlink, skipping" && continue
        ln -sfT "${source}" "${target}"
        echo "  ${value.target} -> (store)"
      ''
    ) staticFiles
  );
in
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
      vicos.packages.vvim-unfree.impure

      # WSL utilities
      pkgs.wslu # wslview, wslpath, etc.
    ];

    home.configFile."nvim" = {
      source = config.lib.vicos.stash "config/nvim";
      recursive = true;
    };

    config.networking.useNetworkd = false;

    # Use Windows browser via wslview
    environment.sessionVariables = {
      BROWSER = "wslview";
    };

    # WSL-specific configuration
    wsl = {
      enable = true;
      defaultUser = user;
      # Use Windows OpenGL for GUI apps
      useWindowsDriver = true;
    };
  };
}
