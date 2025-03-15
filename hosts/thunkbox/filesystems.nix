{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/be1d33dc-19a9-41b3-be32-0d6f6f66901d";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D95D-975A";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/memes" = {
    device = "/dev/disk/by-uuid/ce75bf24-f055-4fbf-a994-4a9e978aff2f";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/c12d2d56-509c-4056-807e-c18d75257602"; }
  ];
}
