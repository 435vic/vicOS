{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: let
    inherit (self) outputs;
    localpkgs = import ./packages nixpkgs.legacyPackages.x86_64-linux;
  in {

    packages.x86_64-linux = localpkgs;

    nixosConfigurations = {
      thunksquare = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        #specialArgs = { inherit localpkgs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.vico = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = { inherit inputs outputs localpkgs; };
	  }
        ];
      };
    };
  };
}
