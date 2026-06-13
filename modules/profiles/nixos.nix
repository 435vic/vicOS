{ pkgs, ... }: {
  # base programs useful for any nixos system
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.procps
    pkgs.psmisc
    pkgs.xdg-utils
  ];
}
