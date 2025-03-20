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

    vicosCats = import ./nixcats.nix inputs.nixCats;
    nixCatsModule = nixCats.utils.mkNixosModules {
      inherit (vicosCats) luaPath categoryDefinitions packageDefinitions;
      nixpgks = nixpkgs-unstable;
      defaultPackageName = vicosCats.default;
    };

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
          nixCatsModule
          ./modules
          ./.secrets/modules
          {
            nixpkgs.pkgs = pkgs;
            networking.hostName = name;
            vicos.flake = vicos // {
              packages = self.packages.${system};
            };
          }
          configuration
        ];
      };
  in forEachSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    defaultNixCat = vicosCats.builder nixpkgs-unstable system vicosCats.default;
  in {
    formatter = pkgs.alejandra;
    legacyPackages = import ./packages pkgs;
    packages = nixCats.utils.mkAllPackages defaultNixCat;
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
