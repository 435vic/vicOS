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
    environment.sessionVariables = roots;
    environment.localBinInPath = true;

    environment.etc."environment.d/60-vicos-xdg.conf".text = ''
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}=${value}") roots)}
      PATH=$HOME/.local/bin:''${PATH}
    '';

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
