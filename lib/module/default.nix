{ lib }:
lib.foldl (a: b: a // b) { } [
  (import ./files.nix { inherit lib; })
  (import ./inputs.nix { inherit lib; })
]
