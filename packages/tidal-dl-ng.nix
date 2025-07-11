{
  python3Packages,
  lib,
  ffmpeg,
  fetchPypi,
  ...
}: python3Packages.buildPythonPackage rec {
  pname = "tidal-dl-ng";
  version = "0.26.2";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "tidal_dl_ng";
    hash = "sha256-mguTwHF5oiI/3RE9iOgGUX7LaEFeXARg8XL2LxR6fXE=";
  };

  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    requests
    mutagen
    dataclasses-json
    pathvalidate
    m3u8
    coloredlogs
    rich
    toml
    typer
    tidalapi
    python-ffmpeg
    pycryptodome
  ];

  pythonRelaxDeps = [
    "requests"
    "pathvalidate"
    "typer"
  ];
}
