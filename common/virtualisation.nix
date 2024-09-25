{
  pkgs,
  libs,
  ...
}:
{
  vitualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.supergfxd.enable = true;

  environment.SystemPackages = with pkgs; [
    supergfxctl
  ];
}
