{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.fish.enable = true;
  programs.direnv.enable = true;
  programs.direnv.enableFishIntegration = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      ripgrep
      wget
      jq
      eza
      bat
      gitui
      gitFull
      nix-search-cli
      fzf
      fd
      nil
      nixd
      ;

    ghostty-terminfo = pkgs.ghostty.terminfo;
  };

  # extremely slow, has to be rebuilt everytime the installed packages list changes, which
  # is almost every rebuild.
  documentation.man.generateCaches = lib.mkForce false;

  programs.fish.shellAliases = {
    "ls" = "eza";
    "cat" = "bat";
    "grep" = "rg";
  };

  programs.bash.interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';

  programs.fish.interactiveShellInit = lib.mkAfter ''
    # disable fish greeting
    set -U fish_greeting
    # vi mode on everything
    set -g fish_key_bindings fish_vi_key_bindings
    # set fish as the default shell if on interactive mode
    set -x SHELL fish
  '';

  home.configFile.fish = {
    source = config.lib.vicos.stash "config/fish";
    recursive = true;
  };
}
