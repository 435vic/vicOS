{
  vicos,
  pkgsDefaults
}: {
  # TODO: allow custom pkgs configuration per host
  mkHost = {
    name,
    system,
    extraModules ? []
  }: let
    inherit (vicos.inputs) nixpkgs nixpkgs-unstable;

    # AFAIK this is the best approach to configuring nixpkgs if you intend to use unstable packages at the same time.
    # just keep in mind you need to set the nixpkgs.pkgs option to this import so you can use it in your configuration.
    pkgs = import nixpkgs {
      inherit system;

      # We expose nixpkgs-unstable through an overlay for convenience. Yes, we do evaluate nixpkgs twice but it's necessary
      # in order to use both the stable and unstable branches at the same time. Using inputs.nixpkgs-unstable.legacyPackages will still
      # import nixpkgs anyway.
      overlays = [
        (self: super: {
          unstable = import nixpkgs-unstable { inherit system; } // pkgsDefaults;
        })
      ];

    } // pkgsDefaults;

  in nixpkgs.lib.nixosSystem {
    modules = [
      # making nixpkgs.* read only makes sure all config is done in one spot. Makes it easier to maintain.
      nixpkgs.nixosModules.readOnlyPkgs
      {
        nixpkgs.pkgs = pkgs;
        networking.hostName = name;
      }
      {
        # We inject all flake related thingamabobs through the module system.
        # I reluctantly agreed due to https://jade.fyi/blog/flakes-arent-real/
        vicos.flake = {
          inherit (vicos) path lib;
          inherit system;

          modules = with vicos; lib.flattenFlakeModules inputs;
        };
      }
    ] ++ extraModules;
  };
}