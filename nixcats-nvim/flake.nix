{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };
  
  outputs = { nixpkgs, nixCats, ... }: let
    vicosCats = import ./default.nix nixCats;
  in nixCats.utils.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system: {
    packages = vicosCats.mkNvimPackages { inherit nixpkgs system; };
  });
}
