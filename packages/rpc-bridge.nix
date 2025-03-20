{
  lib,
  stdenv,
  wine,
  pkgsCross,
  fetchFromGitHub,
  ...
}: let
  tag = "v1.2";
  pname = "rpc-bridge";
in
  stdenv.mkDerivation {
    inherit pname;
    version = tag;

    src = fetchFromGitHub {
      inherit tag;
      owner = "EnderIce2";
      repo = pname;
      hash = "sha256-Wy823yc16Lk0HdUOteWsuzTT9N20x7MRVs4hhlNlj/I=";
    };

    nativeBuildInputs = [pkgsCross.mingwW64.stdenv.cc wine];

    postBuild = ''
      substituteInPlace build/bridge.sh \
        --replace-fail "bridge.exe" "rpc-bridge.exe"
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp build/bridge.exe $out/bin/rpc-bridge.exe
      cp build/bridge.sh $out/bin/rpc-bridge.sh
    '';
  }
