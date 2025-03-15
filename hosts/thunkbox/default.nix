{ inputs, ... }: {
  system = "x86_64-linux";

  configuration = { config, lib, ... }: {
    imports = [
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga503
      ./filesystems.nix
    ];

    vicos = {
      username = "vico";

      hardware = {
        laptop.enable = true;
        audio.enable = true;
      };

      desktop = {
        enable = true;
        hyprland.enable = true;
      };

      shell = {
        fish.runByDefault = true;
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

    networking.useDHCP = lib.mkDefault true;

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
    boot.initrd.kernelModules = [ "amdgpu" ];

    # TODO: Move to a emulation module
    boot.kernelModules = [ "kvm-amd" ];
  };
}