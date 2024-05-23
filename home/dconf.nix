# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      icon-theme = "Adwaita";
      show-battery-percentage = true;
      text-scaling-factor = 1.25;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = ["blur-my-shell@aunetx"];
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      brightness = 1.0;
      dynamic-opacity = false;
      enable-all = false;
      opacity = 255;
      sigma = 9;
      whitelist = ["Alacritty"];
    };
  };
}
