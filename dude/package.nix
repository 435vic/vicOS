{
  haskellPackages,
  haskell,
  returnShellEnv ? false,
  ...
}: let
  devDependencies = with haskellPackages; [
    haskell-language-server
    cabal-install
  ];
  shellEnvModifier = drv: haskell.lib.addBuildTools drv devDependencies;
in haskellPackages.developPackage {
  inherit returnShellEnv;
  root = ./.;
  name = "dude";
  modifier = if returnShellEnv then shellEnvModifier else drv: drv;
}