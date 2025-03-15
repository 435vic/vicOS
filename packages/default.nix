pkgs: {
  tokyo-night-sddm = pkgs.libsForQt5.callPackage ./tokyo-night-sddm.nix { };
  northstar-proton = pkgs.callPackage ./northstar-proton.nix { };
  viper = pkgs.callPackage ./viper.nix { };
}
