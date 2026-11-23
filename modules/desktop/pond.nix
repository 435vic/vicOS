{
  config,
  lib,
  pkgs,
  ...
}:
# Pond's userspace (github.com/bflycomputer/pond-interface), adapted for
# Hyprland: the lockscreen and shell are vendored under config/quickshell, and
# packages/pond-interface supplies their compiled QML modules.
let
  cfg = config.vicos;
  pondInterface = pkgs.callPackage ../../packages/pond-interface { };
  # Commands the shell runs: the Bluetooth pairing agent, audio port names and
  # Wi-Fi link details. nmcli comes from the system where NetworkManager runs.
  shellTools = [
    (pkgs.python3.withPackages (ps: [ ps.pygobject3 ]))
    pkgs.pulseaudio
    pkgs.iw
  ];
  quickshellWrapArgs = [
    "--prefix QML_IMPORT_PATH : ${pondInterface}/${pkgs.qt6.qtbase.qtQmlPrefix}"
    "--prefix PATH : ${lib.makeBinPath shellTools}"
    "--set-default QS_ICON_THEME Papirus-Dark"
  ]
  ++ lib.optionals config.services.fprintd.enable [
    "--set-default POND_FPRINT_PAM_SERVICE pond-lock-fprint"
  ];
  quickshell = pkgs.symlinkJoin {
    name = "quickshell-pond";
    paths = [ pkgs.quickshell ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in $out/bin/*; do
        wrapProgram "$bin" ${lib.concatStringsSep " " quickshellWrapArgs}
      done
    '';
    inherit (pkgs.quickshell) meta;
  };
  # Pond's launcher palettes from Butterfly's Vicinae fork. Vanilla Vicinae finds
  # them under XDG_DATA_DIRS; the fork's card gradients live in its QML and
  # don't come along.
  launcherThemes = pkgs.runCommand "pond-vicinae-themes" {
    src = pkgs.fetchFromGitHub {
      owner = "bflycomputer";
      repo = "vicinae";
      rev = "68847f4b70ecf2a723859d39032e857dccb7691c";
      sparseCheckout = [ "extra/themes" ];
      hash = "sha256-YN4wsBAfeJ1ex+UpPQrZAHkeh9KhSqun3f+Fei5GMSU=";
    };
  } ''install -Dm644 $src/extra/themes/*.toml -t $out/share/vicinae/themes'';
  # Reuse a running lockscreen, or start one. Pond's lockscreen locks on start.
  pondLock = pkgs.writeShellApplication {
    name = "pond-lock";
    runtimeInputs = [ quickshell ];
    text = ''
      qs -c lockscreen ipc call lockscreen lock 2>/dev/null || qs -d -c lockscreen
    '';
  };
in
{
  options.vicos.desktop.pond = {
    quickshell = lib.mkOption {
      type = lib.types.package;
      internal = true;
      readOnly = true;
      default = quickshell;
      description = "Quickshell with Pond's QML modules on its import path.";
    };
    lock = lib.mkOption {
      type = lib.types.package;
      internal = true;
      readOnly = true;
      default = pondLock;
      description = "Command that locks the session with Pond's lockscreen.";
    };
  };

  config = lib.mkIf cfg.desktop.enable {
    environment.systemPackages = [
      quickshell
      pondLock
      launcherThemes
    ];
    environment.pathsToLink = [ "/share/vicinae/themes" ];
    # Imported from ~/.config/vicinae/settings.json, which Vicinae itself writes.
    stash = lib.mkIf (cfg.user != null) {
      users.${cfg.user}.files."${cfg.xdg.configHome}/vicinae/pond.jsonc".source =
        config.lib.stash.fromStash {
          stash = "vicos";
          path = "config/vicinae/pond.jsonc";
        };
    };
    # Password and fingerprint run in parallel PAM contexts so either unlocks
    # immediately without blocking the other.
    security.pam.services.pond-lock.fprintAuth = false;
    security.pam.services.pond-lock-fprint = lib.mkIf config.services.fprintd.enable {
      unixAuth = false;
      fprintAuth = true;
    };

    # Pond's boot, LUKS prompt, shutdown and restart animations. A quiet boot
    # keeps kernel and udev messages from drawing over the splash.
    boot.plymouth = {
      enable = true;
      theme = "pond";
      themePackages = [ pondInterface ];
    };
    boot.consoleLogLevel = 3;
    boot.kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];

    fonts.packages = [
      (pkgs.google-fonts.override {
        fonts = [
          "Onest"
          "Advent Pro"
          # Stands in for Pond Gramercy, Pond's proprietary title font.
          "Piazzolla"
        ];
      })
      pkgs.ibm-plex
      pkgs.jetbrains-mono
    ];
  };
}
