{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "renix.sh" (builtins.readFile ./renix.sh))
  ];
}
