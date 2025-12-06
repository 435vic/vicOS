{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.vicos = {
    desktop.termAppExtraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        Extra terminal emulator args to pass to terminal apps' desktop entries.
        The substring `@pname@` will be substituted with the program's `pname`.
        NOTE: most args are specific to their terminal emulators! change this option if you
        change the terminal emulator for desktop entries.
      '';
      default = [
        "--confirm-close-surface=false"
        "--title=@pname@"
      ];
    };

    desktop.termAppEmulator = lib.mkOption {
      type = lib.types.package;
      description = "Terminal emulator to use for desktop entries for terminal apps, like wiremix.";
      default = pkgs.ghostty;
    };
  };

  config = {
    # TODO: add alternate launcher options (walker?)
    home.configFile.rofi = {
      source = config.lib.vicos.stash "config/rofi";
      recursive = true;
    };

    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

    environment.systemPackages = [
      pkgs.rofi-unwrapped
      (config.lib.vicos.makeTUIApplication {
        name = "wiremix";
        program = pkgs.wiremix;
        desktopName = "Wiremix";
        genericName = "Volume Control";
        comment = "Adjust the volume level";
        icon = ../../packages/wiremix/wiremix.png;
        startupNotify = true;
        categories = [
          "AudioVideo"
          "Audio"
          "Mixer"
          "Settings"
        ];
        keywords = [
          "PipeWire"
          "PulseAudio"
          "Microphone"
          "Volume"
          "Balance"
          "Headset"
          "Speakers"
          "Headphones"
          "Audio"
          "Mixer"
          "Output"
          "Input"
          "Devices"
          "Playback"
          "Recording"
          "Sound Card"
          "Settings"
        ];
      })
    ];

    lib.vicos.makeTUIApplication =
      {
        program,
        termArgs ? [ ],
        ...
      }@args:
      let
        termArgsStr = builtins.replaceStrings [ "@pname@" ] [ program.pname ] (
          builtins.concatStringsSep " " termArgs
        );

        exec = lib.getExe program;
      in
      pkgs.makeDesktopItem (
        (builtins.removeAttrs args [
          "program"
          "termArgs"
        ])
        // {
          exec = "${pkgs.ghostty}/bin/ghostty ${termArgsStr} -e ${exec}";
        }
      );
  };
}
