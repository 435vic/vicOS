{ vicos, ... }:
{
  imports = [
    ./base.nix
    ../shell/fish.nix
    ../shell/tmux.nix
    ../shell/shell.nix
  ];

  environment.systemPackages = [
    vicos.packages.vvim
  ];
}
