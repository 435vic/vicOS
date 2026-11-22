{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
in
{
  config = lib.mkIf cfg.desktop.enable {
    # Steam ignores XDG and litters $HOME with ~/.steam, ~/.steampath and
    # ~/.steampid; native games launched from it often do the same. Following
    # hlissner/dotfiles (modules/games/steam.nix, "Obey XDG, damn it!"), give
    # Steam's FHS environment a fake $HOME. Steam still puts its library under
    # the real $XDG_DATA_HOME/Steam because the session exports absolute XDG
    # roots. His tricks we skip: -pipewire for Remote Play on Wayland (we stream
    # with Sunshine) and blanking DBUS_SYSTEM_BUS_ADDRESS to skip Steam's
    # NetworkManager wait at login.
    # See also ValveSoftware/steam-for-linux#1890.
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraProfile = ''
          export VICOS_FAKE_HOME="''${VICOS_FAKE_HOME:-$HOME/.local/user}"
          mkdir -p -m 700 "$VICOS_FAKE_HOME"
          export HOME="$VICOS_FAKE_HOME"
        '';
      };
    };

    programs.gamescope.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = [
      pkgs.lutris
      pkgs.protonup-ng
    ];

    # protonup-ng defaults to ~/.steam/root/compatibilitytools.d, which only
    # exists inside Steam's fake $HOME.
    stash.users = lib.mkIf (cfg.user != null) {
      ${cfg.user}.files."${cfg.xdg.configHome}/protonup/config.ini".text = ''
        [protonup]
        installdir = ~/${cfg.xdg.dataHome}/Steam/compatibilitytools.d/
      '';
    };
  };
}
