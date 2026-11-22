{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  app = lib.types.submodule {
    options = {
      package = lib.mkOption {
        type = lib.types.package;
        description = "Package providing the application.";
      };
      desktop = lib.mkOption {
        type = lib.types.str;
        description = "Desktop entry ID used by launchers and MIME associations.";
      };
    };
  };
in
{
  options.vicos.desktop.apps =
    lib.mapAttrs
      (
        name: default:
        lib.mkOption {
          type = app;
          inherit default;
          description = "Default ${name}; the package and desktop entry are selected together.";
        }
      )
      {
        terminal = {
          package = pkgs.ghostty;
          desktop = "com.mitchellh.ghostty.desktop";
        };
        browser =
          if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
            {
              package = pkgs.callPackage ../../packages/helium { enableWideVine = true; };
              desktop = "helium.desktop";
            }
          else
            {
              package = pkgs.firefox;
              desktop = "firefox.desktop";
            };
        editor = {
          package = pkgs.zed-editor;
          desktop = "dev.zed.Zed.desktop";
        };
        fileManager = {
          package = pkgs.nautilus;
          desktop = "org.gnome.Nautilus.desktop";
        };
        pdfViewer = {
          package = pkgs.zathura;
          desktop = "org.pwmt.zathura-pdf-mupdf.desktop";
        };
        imageViewer = {
          package = pkgs.imv;
          desktop = "imv.desktop";
        };
        mediaPlayer = {
          package = pkgs.mpv;
          desktop = "mpv.desktop";
        };
        mailClient = {
          package = pkgs.thunderbird;
          desktop = "thunderbird.desktop";
        };
      };

  config = lib.mkIf cfg.desktop.enable (
    lib.mkMerge [
      {
        services.gvfs.enable = true;
        programs.dconf.enable = true;
        programs.obs-studio.enable = true;
      }
      (lib.mkIf (cfg.user != null) {
        users.users.${cfg.user}.packages =
          map (app: app.package) (builtins.attrValues cfg.desktop.apps)
          ++ [
            pkgs.xdg-utils
            pkgs.xdg-terminal-exec
          ];

        stash.users.${cfg.user}.files."${cfg.xdg.configHome}/xdg-terminals.list".text =
          "${cfg.desktop.apps.terminal.desktop}\n";
      })
    ]
  );
}
