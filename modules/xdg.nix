{
  config,
  lib,
  ...
}:
let
  cfg = config.vicos;
  roots = {
    XDG_CONFIG_HOME = "$HOME/${cfg.xdg.configHome}";
    XDG_DATA_HOME = "$HOME/${cfg.xdg.dataHome}";
    XDG_STATE_HOME = "$HOME/${cfg.xdg.stateHome}";
    XDG_CACHE_HOME = "$HOME/${cfg.xdg.cacheHome}";
  };
in
{
  # HOME-relative strings work for every account, unlike absolute Nix paths.
  # These are shared constants, not relocation controls.
  options.vicos.xdg =
    lib.mapAttrs
      (
        name: path:
        lib.mkOption {
          type = lib.types.str;
          default = path;
          readOnly = true;
          description = "Fixed HOME-relative XDG ${lib.removeSuffix "Home" name} directory.";
        }
      )
      {
        configHome = ".config";
        dataHome = ".local/share";
        stateHome = ".local/state";
        cacheHome = ".cache";
      };

  config = lib.mkIf cfg.cli.enable {
    # Native NixOS propagation: PAM and shell initialisation. These conventional
    # defaults are host-wide; never put a particular user's absolute home here.
    environment.sessionVariables = roots;
    environment.localBinInPath = true;

    # environment.d supplies user services, including starts without a shell.
    # PAM/login/compositor integration and XDG_RUNTIME_DIR remain fleet-owned.
    environment.etc."environment.d/60-vicos-xdg.conf".text = ''
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${value}") roots)}
      PATH=$HOME/.local/bin:''${PATH}
    '';

    # ':' applies the private mode only when creating a directory. Do not
    # chmod existing user data, clean directories, or migrate legacy paths.
    systemd.user.tmpfiles.rules = map (path: ''d "%h/${path}" :0700 - - -'') [
      cfg.xdg.configHome
      cfg.xdg.cacheHome
      ".local"
      cfg.xdg.dataHome
      cfg.xdg.stateHome
      ".local/bin"
    ];
  };
}
