{
  pkgs,
  libs,
  ...
}:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.supergfxd.enable = true;

  environment.systemPackages = with pkgs; [
    supergfxctl
  ];
}
