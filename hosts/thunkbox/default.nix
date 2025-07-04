{inputs, ...}: {
  system = "x86_64-linux";
  unstable = true;

  configuration = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
      ./filesystems.nix
      ./REFACTORME_fonts.nix # for the love of god refactor this to the theme modules
    ];

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

    vicos = {
      username = "vico";

      hardware = {
        laptop.enable = true;
        laptop.quietBoot = true;
        audio.enable = true;
        wifi.enable = true;
        wifi.interfaces = [ "wlp4s0" ];
      };

      desktop = {
        enable = true;
        # nix-ld.enable = true;
        rofi.enable = true;
        hyprland = {
          enable = true;
          monitors = [
            {
              selector = "desc:Chimei Innolux Corporation 0x1540";
              mode = "2560x1440@165";
              position = "0x0";
              scale = 1;
            }
            {
              selector = "desc:LG Electronics LG ULTRAGEAR 0x00003B2A";
              mode = "1920x1080@165";
              position = "2560x0";
              scale = 1;
              primary = true;
            }
          ];
        };

        apps = {
          discord.enable = true;
          spotify.enable = true;
          cad.enable = true;
        };

        gaming.enable = true;
        gaming.enableExtraPackages = true;
        gaming.tetrio.enable = true;

        term.ghostty = {
          enable = true;
          # NOTE: workaround patch for https://github.com/ghostty-org/ghostty/issues/7724
          # Change when switching to linux 6.15.5
          package = pkgs.unstable.ghostty.overrideAttrs (_: {
            preBuild = ''
              shopt -s globstar
              sed -i 's/^const xev = @import("xev");$/const xev = @import("xev").Epoll;/' **/*.zig
              shopt -u globstar
            '';
          });
        };

        browser = {
          enable = true;
          zen.enable = true;
        };
      };

      services = {
        waybar.enable = true;
      };

      # a lot easier while I figure out vim
      dev.nvim.pure = false;

      shell = {
        fish.runByDefault = true;
        starship.enable = true;
        tmux.enable = true;
        git = {
          name = "Victor Quintana";
          email = "435victorjavier@gmail.com";
        };
      };
    };

    programs.zoxide.enable = true;

    environment.systemPackages = with pkgs; [
      typst # better latex
    ];

    services.asusd = {
      enable = true;
      enableUserService = true;
    };

    services.restic.backups = let
      excludes = pkgs.writeText "fd-excludes" ''
        /home/vico/.*
        /home/vico/Downloads
        Unity
        node_modules
        *~
        *.o
        *.lo
        *.pyc
        *.class
        .venv
        .git
        target
        dist
      '';
    in {
      local = let
        includeFile = "/run/restic-backups-local/raw_include";
      in {
        initialize = true;
        passwordFile = "/run/agenix/rustic-password";

        # can't negate patters with ! on fd
        # so we gotta include these paths manually
        # see https://github.com/sharkdp/fd/issues/1457#issuecomment-1880604708
        paths = [
          "/home/vico/.local/share/PrismLauncher"
          "/home/vico/.local/user/Pictures"
          "/home/vico/.local/user/Documents"
          "/home/vico/vicOS"
        ];

        extraBackupArgs = [
          "--files-from-raw=${includeFile}"
        ];

        repository = "/mnt/memes/backup";
        backupPrepareCommand = "${pkgs.fd}/bin/fd . /home/vico -aH -tfile --ignore-file ${excludes} --print0 >> ${includeFile}";
        backupCleanupCommand = "rm ${includeFile}";
      };
    };

    virtualisation.docker.enable = true;

    # TODO: decide whether to include this on modules or not
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.hyprland.enableGnomeKeyring = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    # -=-=-=-=-=- MOVE THIS CONFIG TO MODULES!! -=-=-=-=-=-
    # TODO: move to hardware modules (perhaps with a profile system?)
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    boot.initrd.kernelModules = ["amdgpu"];
    # defined by hardware
    services.xserver = {
      videoDrivers = ["amdgpu" "nvidia"];
    };

    # TODO: Move to a emulation module
    boot.kernelModules = ["kvm-amd"];
  };
}
