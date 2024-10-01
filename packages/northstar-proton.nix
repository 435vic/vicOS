{
  lib,
  fetchzip,
  stdenv,
}:
let
  pname = "NorthstarProton";
  version = "8-28";

  src = fetchzip {
    url = "https://github.com/R2NorthstarTools/${pname}/releases/download/v${version}/${pname}${version}.tar.gz";
    hash = "sha256-wCWFnirscv+oKs6v+ZNXVwM/ZnSZsjvMUt/ZKbKZnMg=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  installPhase = "cp -r ./ $out";

  meta = {
    description = "A Proton build based on TKG's proton-tkg build system to run the Northstar client on Linux and SteamDeck";
    homepage = "https://github.com/cyrv6737/NorthstarProton";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ NotAShelf ];
    platforms = [ "x86_64-linux" ];
  };
}
