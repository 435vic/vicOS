pkgs: rec {
  # tokyo-night-sddm = pkgs.libsForQt5.callPackage ./tokyo-night-sddm.nix { };
  northstar-proton = pkgs.callPackage ./northstar-proton.nix { };
  viper = pkgs.callPackage ./viper.nix { };
  nordzy-cursors = pkgs.callPackage ./nordzy-cursors.nix { };
  tidalapi = pkgs.python3Packages.callPackage ./tidal-dl-ng/tidalapi.nix { };
  tidal-dl-ng = pkgs.python3Packages.callPackage ./tidal-dl-ng { inherit tidalapi; };
  helium = pkgs.callPackage ./helium.nix { };
}
