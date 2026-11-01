{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  wget = pkgs.writeShellScriptBin "wget" ''
    state_home="''${XDG_STATE_HOME:-$HOME/${cfg.xdg.stateHome}}"
    (umask 077; ${lib.getExe' pkgs.coreutils "mkdir"} -p -- "$state_home/wget")
    exec ${lib.getExe pkgs.wget} --hsts-file="$state_home/wget/hsts" "$@"
  '';
in
{
  options.vicos.cli.enable = lib.mkEnableOption "the common personal CLI environment";

  config = lib.mkIf cfg.cli.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ wget ];
        environment.sessionVariables.LESSHISTFILE = "$HOME/${cfg.xdg.stateHome}/less/history";
        environment.etc."environment.d/70-vicos-cli.conf".text = ''
          LESSHISTFILE=$HOME/${cfg.xdg.stateHome}/less/history
        '';

        programs.bash.shellInit = lib.mkAfter ''
          export HISTFILE="''${XDG_STATE_HOME:-$HOME/${cfg.xdg.stateHome}}/bash/history"
          (umask 077; ${lib.getExe' pkgs.coreutils "mkdir"} -p -- "''${HISTFILE%/*}")
        '';

        environment.extraInit = ''
          (umask 077; ${lib.getExe' pkgs.coreutils "mkdir"} -p -- "''${LESSHISTFILE%/*}")
        '';
        systemd.user.tmpfiles.rules = [
          ''d "%h/${cfg.xdg.stateHome}/bash" :0700 - - -''
          ''d "%h/${cfg.xdg.stateHome}/less" :0700 - - -''
        ];

        assertions = [
          {
            assertion = cfg.user != null;
            message = "vicos.cli.enable requires vicos.user to name an existing normal user.";
          }
        ];
      }
      (lib.mkIf (cfg.user != null) {
        assertions = [
          {
            assertion = config.users.users.${cfg.user}.isNormalUser;
            message = "vicOS does not create accounts: declare vicos.user as a normal user in the fleet configuration.";
          }
        ];

        users.users.${cfg.user}.packages = with pkgs; [
          bat
          btop
          curl
          delta
          eza
          fd
          file
          fzf
          ghostty.terminfo
          gitui
          jq
          less
          lsof
          ncdu
          nh
          nix-output-monitor
          nix-search-cli
          nix-tree
          p7zip
          ripgrep
          rsync
          tree
          unzip
          yq-go
          zip
          config.lib.stash.packages.stash-cli
        ];

        stash.users.${cfg.user}.stashes.vicos.path = cfg.dotfilesPath;
      })
    ]
  );
}
