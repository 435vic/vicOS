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

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = "Nordzy-cursors";
            };
          };
        }
      ];
    };

    vicos = {
      username = "vico";

      # Theme stuff, should probably go in a theme module
      user.packages = [
        config.vicos.flake.packages.nordzy-cursors
      ];

      hardware = {
        laptop.enable = true;
        laptop.quietBoot = true;
        audio.enable = true;
        wifi.enable = true;
        wifi.interfaces = [ "wlp4s0" ];
      };

      desktop = {
        enable = true;
        rofi.enable = true;
        hyprland = {
          enable = true;
          environmentVariables = {
            HYPRCURSOR_THEME = "Nordzy-cursors";
            XCURSOR_THEME = "Nordzy-cursors";
            HYPRCURSOR_SIZE = "24";
          };
        };

        apps = {
          discord.enable = true;
          spotify.enable = true;
          cad.enable = true;
        };

        gaming.enable = true;
        gaming.enableExtraPackages = true;
        gaming.tetrio.enable = true;

        term.ghostty.enable = true;

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

    services.asusd = {
      enable = true;
      enableUserService = true;
    };

    virtualisation.docker.enable = true;


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
