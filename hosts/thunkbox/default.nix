{inputs, ...}: {
  system = "x86_64-linux";

  configuration = {
    config,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
      ./filesystems.nix
      ./REFACTORME_fonts.nix # for the love of god refactor this to the theme modules
    ];

    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

    vicos = {
      username = "vico";
      hardware = {
        laptop.enable = true;
        laptop.quietBoot = true;
        audio.enable = true;
        wifi.enable = true;
      };

      desktop = {
        enable = true;
        rofi.enable = true;
        hyprland.enable = true;

        apps = {
          discord.enable = true;
          spotify.enable = true;
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
        git = {
          name = "Victor Quintana";
          email = "435victorjavier@gmail.com";
        };
      };
    };

    services.asusd = {
      enable = true;
      enableUserService = true;
    };

    networking.wireless.interfaces = ["wlp4s0"];

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
