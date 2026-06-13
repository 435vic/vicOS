{ vicos, ... }:
{
  imports = [
    ./base.nix
    ./nixos.nix
    ../shell/fish.nix
    ../shell/tmux.nix
    ../shell/shell.nix
  ];

  environment.systemPackages = [
    vicos.packages.vvim
  ];
}
