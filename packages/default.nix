pkgs: {
  # tokyo-night-sddm = pkgs.libsForQt5.callPackage ./tokyo-night-sddm.nix { };
  northstar-proton = pkgs.callPackage ./northstar-proton.nix {};
  viper = pkgs.callPackage ./viper.nix {};
  rpc-bridge = pkgs.callPackage ./rpc-bridge.nix {};
  nordzy-cursors = pkgs.callPackage ./nordzy-cursors.nix {};
  # nix-search = pkgs.callPackage ./nix-search.nix { };
}
