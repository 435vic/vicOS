{ lib }:
let
  inherit (lib) mapAttrs pipe filterAttrs;
in {
  flattenFlakeModules = inputs: pipe inputs [
    (filterAttrs (_: input: input ? nixosModules))
    (mapAttrs (_: input: input.nixosModules))
  ];
}