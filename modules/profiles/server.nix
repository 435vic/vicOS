{ vicos, ... }:
{
  imports = [
    ./base.nix
    ./nixos.nix
    ../shell/fish.nix
    ../shell/tmux.nix
    ../shell/shell.nix
    ../shell/amp.nix
  ];

  environment.systemPackages = [
    vicos.packages.vvim
  ];
}
