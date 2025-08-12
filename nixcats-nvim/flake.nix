{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };
  
  outputs = { nixpkgs, nixCats, ... }: let
    vicosCats = import ./default.nix nixCats;
    vicosNvims = system: vicosCats.mkNvimPackages { inherit nixpkgs system; };
  in (nixCats.utils.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system: {
    packages = vicosNvims system;
  })) // {
    overlays.default = final: prev: {
      vicovim = vicosNvims final.stdenv.hostPlatform.system;
    };
  };
}
