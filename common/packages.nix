# once again taken from the wonderful sioodmy and their dotfiles
{pkgs, ...}: with pkgs; [
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
]
