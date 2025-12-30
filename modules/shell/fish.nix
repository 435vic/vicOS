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
      export SHELL=fish
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';

  home.configFile.fish = {
    source = config.lib.vicos.stash "config/fish";
    recursive = true;
  };
}
