{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (writeScriptBin "dontkillsteam.sh" ''
      if [[ $(hyprctl activewindow -j | jq -r ".class") == "Steam" ]]; then
          xdotool windowunmap $(xdotool getactivewindow)
      else
          hyprctl dispatch killactive ""
      fi
    '')
    (writeScriptBin "screenshot.sh" (builtins.readFile ./screenshot.sh))
    (writeScriptBin "rofilaunch.sh" (builtins.readFile ./rofilaunch.sh))
    (writeScriptBin "gamemode.sh" (builtins.readFile ./gamemode.sh))
  ];
}
