{ pkgs, config, ... }:
{
  programs.fish.enable = true;
  programs.direnv.enable = true;
  programs.direnv.enableFishIntegration = true;
  programs.starship.enable = true;
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      ripgrep
      jq
      eza
      bat
      gitui
      nix-search-cli
      fzf
      fd
      nil
      nixd
      ;
  };

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
