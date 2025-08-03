{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nordzy-hyprcursor";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "guillaumeboehm";
    repo = "Nordzy-cursors";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pPcdlMa3H5RtbqIxvgxDkP4tw76H2UQujXbrINc3MxE=";
  };

  phases = ["unpackPhase" "installPhase"];

  installPhase = ''
    mkdir -p $out/share/icons/
    cp -R hyprcursors/themes/* $out/share/icons/
    cp -R xcursors/* $out/share/icons/
  '';
})
