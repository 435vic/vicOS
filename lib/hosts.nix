{
  inputs,
  self, # this flake's outputs
  pkgsDefaults,
  ...
}: {
  # TODO: allow custom pkgs configuration per host
  mkHost = {
    name,
    system,
    extraModules ? []
  }: let
    # AFAIK this is the best approach to configuring nixpkgs if you intend to use unstable packages at the same time.
    # just keep in mind you need to set the nixpkgs.pkgs option to this import so you can use it in your configuration.
    pkgs = import inputs.nixpkgs {
      inherit system;

      # We expose nixpkgs-unstable through an overlay for convenience. Yes, we do evaluate nixpkgs twice but it's a necessary
      # to use both the stable and unstable branches at the same time. Using inputs.nixpkgs-unstable.legacyPackages will still
      # import nixpkgs anyway.
      overlays = [
        (self: super: {
          unstable = import inputs.nixpkgs-unstable { inherit system; } // pkgsDefaults;
        })
      ];

    } // pkgsDefaults;
  in inputs.nixpkgs.lib.nixosSystem {
    # don't want to expose the inner config to the flake inputs, would rather use overlays or modules instead.
    specialArgs = {
      inherit self;
    };

    modules = [
      # making nixpkgs.* read only makes sure all config is done in one spot. Makes it easier to maintain.
      inputs.nixpkgs.nixosModules.readOnlyPkgs
      {
        nixpkgs.pkgs = pkgs;
        networking.hostName = name;
      }
    ] ++ extraModules;
  };
}