{
  description = "vicOS v2 - Now with added protein!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs-unstable";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    agenix.url = "github:ryantm/agenix";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    agenix,
    spicetify-nix,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixpkgs.lib) genAttrs mapAttrs;
    inherit (builtins) getEnv;

    forEachSystem = nixCats.utils.eachSystem ["x86_64-linux" "aarch64-linux"];

    vicos = let
      pathEnv = getEnv "DOTFILES_HOME";
      vicosPath =
        if pathEnv == ""
        then abort "DOTFILES_HOME must be set!"
        else pathEnv;
      rev = toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
    in {
      inherit rev inputs;
      lib = import ./lib {inherit (nixpkgs) lib;};
      path = vicosPath;
    };

    pkgsDefaults = {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [];
    };

    vicosCats = import ./nixcats-nvim inputs.nixCats;

    mkHost = {
      name,
      system,
      configuration,
    }: let
      pkgs =
        import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {inherit system;} // pkgsDefaults;
            })
          ];
        }
        // pkgsDefaults;
    in
      nixpkgs.lib.nixosSystem {
        modules = [
          nixpkgs.nixosModules.readOnlyPkgs
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          spicetify-nix.nixosModules.default
          ./modules
          ./.secrets/modules
          {
            nixpkgs.pkgs = pkgs;
            networking.hostName = name;
            vicos.flake = vicos // {
              packages = self.packages.${system} // self.legacyPackages.${system};
            };
          }
          configuration
        ];
      };
  in forEachSystem (system: let
    pkgs = nixpkgs-unstable.legacyPackages.${system};
    nixCat = vicosCats.builder nixpkgs-unstable system vicosCats.default;
    dude = pkgs.callPackage ./dude/package.nix;
    nvimPackages = let
      inherit (nixCat.utils) mergeCatDefs;
      impureOverride = {...}: { settings.wrapRc = false; };
      mkCat = name: def: (nixCat.override { inherit name; }) // {
        impure = nixCat.override {
          inherit name;
          packageDefinitions.${name} = mergeCatDefs nixCat.packageDefinitions.${name} impureOverride;  
        };
      };
    in pkgs.lib.mapAttrs mkCat nixCat.packageDefinitions;
  in {
    formatter = pkgs.alejandra;
    # helps avoiding unnecessary evaluation time on nix flake check/show
    legacyPackages = import ./packages pkgs;
    # these will be checked and parsed on nix flake commands
    packages = {
      dude = dude {};
    } // nvimPackages;

    devShells = {
      dude-dev = dude { returnShellEnv = true; };
    };
  }) // {
    nixosConfigurations = let
      # why specify the name of the host both as the dir/filename and in the config
      # when you can spend more time writing a function to do it for you?
      mkNamedHost = name: config: mkHost (config // {inherit name;});
      # hosts are provided the vicOS object with inputs, context, etc.
      callHost = name: host: mkNamedHost name (host vicos);
    in
      mapAttrs callHost (vicos.lib.getHosts ./hosts);

    lib = import ./lib {inherit (nixpkgs) lib;};
  };
}
