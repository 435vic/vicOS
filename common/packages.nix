# once again inspired from the wonderful sioodmy and their dotfiles
{ pkgs, outputs, ... }:
{
  nixpkgs.overlays = [
    outputs.overlays.localpkgs
  ];

  environment.systemPackages = with pkgs; [
    ripgrep
    git
    gitAndTools.git-credential-manager
    gping
    ffmpeg-full
    nmap
    wget
    fd
    jq
    neovim
    dconf
    unzip
    greetd.tuigreet
    killall
    imagemagick
    p7zip
    #local.tokyo-night-sddm
  ];
}
