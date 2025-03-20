{lib}:
lib.makeExtensible (
  self: let
    callLib = file: import file {inherit lib self;};
  in
    lib.mergeAttrsList [
      (callLib ./files.nix)
    ]
)
