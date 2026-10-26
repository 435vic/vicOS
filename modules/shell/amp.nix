{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.vicos.amp.runner;

  platform =
    {
      x86_64-linux = "linux-x64";
      aarch64-linux = "linux-arm64";
    }.${
      pkgs.stdenv.hostPlatform.system
    };

  amp = pkgs.writeShellApplication {
    name = "amp";
    runtimeInputs = with pkgs; [curl gzip coreutils util-linux ripgrep];
    text = ''
      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
      export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
      export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
      export AMP_HOME="$XDG_DATA_HOME/amp/cli"
      export AMP_LOG_FILE="''${AMP_LOG_FILE:-$XDG_STATE_HOME/amp/cli.log}"

      mkdir -p "$AMP_HOME/bin" "$(dirname "$AMP_LOG_FILE")"

      if [[ ! -x "$AMP_HOME/bin/amp" ]]; then
        (
          # Serialize first use; recheck after another launcher finishes.
          flock 9
          if [[ -x "$AMP_HOME/bin/amp" ]]; then
            exit 0
          fi

          umask 077
          staging=$(mktemp -d "$AMP_HOME/.bootstrap.XXXXXX")
          trap 'rm -rf "$staging"' EXIT
          base=https://static.ampcode.com/cli
          version=$(curl --fail --silent --show-error --location "$base/cli-version.txt")
          if [[ ! "$version" =~ ^[0-9A-Za-z][0-9A-Za-z.+-]*$ ]]; then
            echo "Invalid Amp release version: $version" >&2
            exit 1
          fi

          echo "Installing Amp $version into $AMP_HOME" >&2
          curl --fail --silent --show-error --location \
            "$base/$version/amp-${platform}.gz" -o "$staging/amp.gz"
          gzip -dc "$staging/amp.gz" > "$staging/amp"
          checksum=$(curl --fail --silent --show-error --location \
            "$base/$version/${platform}-amp.sha256")
          printf '%s  %s\n' "$checksum" "$staging/amp" | sha256sum --check --status
          chmod 0755 "$staging/amp"
          mv "$staging/amp" "$AMP_HOME/bin/amp"
        ) 9>"$AMP_HOME/bootstrap.lock"
      fi

      # Amp and its children resolve the mutable binary, including on restart.
      export PATH="$AMP_HOME/bin:$PATH"
      exec "$AMP_HOME/bin/amp" "$@"
    '';
  };
in {
  options.vicos.amp.runner = {
    enable = lib.mkEnableOption "the Amp runner for vicos.user (log in with amp login first)";

    directories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["/home/vico/code/my-project"];
      description = "Additional directories to serve, passed as repeated --dir flags.";
    };

    serveCwd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to serve the starting directory (the primary user's home).";
    };

    discover = lib.mkEnableOption "automatic discovery of Git checkouts beneath the primary user's home";

    discoverDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["/home/vico/projects"];
      description = ''
        Directories to scan for Git checkouts when discover is enabled.
        An empty list scans the primary user's home directory.
      '';
    };

    discoverDepth = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 2;
      example = 4;
      description = "Directory levels below each discovery root to scan for Git checkouts, passed as --discover-depth when discover is enabled.";
    };

    desktop = lib.mkEnableOption "Amp's private virtual desktop sharing";
    remoteControlTerminal = lib.mkEnableOption "terminal access from ampcode.com";
  };

  config = {
    # Required for upstream ELF binaries, including future self-updates.
    programs.nix-ld.enable = true;
    environment.systemPackages = [amp];

    systemd.user.services.amp-runner = lib.mkIf cfg.enable {
      description = "Amp runner";
      wantedBy = ["default.target"];
      unitConfig.ConditionUser = config.vicos.user;

      path =
        ["/run/current-system/sw" "%h/.nix-profile"]
        ++ lib.optionals cfg.desktop (with pkgs; [labwc wlr-randr ffmpeg dbus]);

      serviceConfig = {
        WorkingDirectory = config.users.users.${config.vicos.user}.home;
        ExecStart = utils.escapeSystemdExecArgs (
          ["${amp}/bin/amp" "--no-tui" "--runner-id" config.networking.hostName]
          ++ lib.optional (!cfg.serveCwd) "--no-serve-cwd"
          ++ lib.concatMap (dir: ["--dir" dir]) cfg.directories
          ++ lib.optionals cfg.discover (
            if cfg.discoverDirectories == []
            then ["--discover-dirs"]
            else lib.concatMap (dir: ["--discover-dirs" dir]) cfg.discoverDirectories
          )
          ++ lib.optionals cfg.discover ["--discover-depth" (toString cfg.discoverDepth)]
          ++ lib.optional cfg.desktop "--desktop"
          ++ [
            (
              if cfg.remoteControlTerminal
              then "--remote-control-terminal"
              else "--no-remote-control-terminal"
            )
          ]
        );
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
