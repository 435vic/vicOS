{ lib }:
lib.foldl (a: b: a // b) {} [
  (import ./files.nix { inherit lib; })
]
