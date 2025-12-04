{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  requests,
  mutagen,
  dataclasses-json,
  pathvalidate,
  m3u8,
  coloredlogs,
  rich,
  toml,
  typer,
  python-ffmpeg,
  pycryptodome,
  poetry-core,
  tidalapi,
  ...
}: buildPythonPackage rec {
  pname = "tidal-dl-ng";
  version = "0.30.0";
  pyproject = true;

  src = fetchFromGitHub {
    inherit version;
    owner = "exislow";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-7+9ywQsu6JPvns8x9ku9O/00/DZHhdB9ghaQgdQPIyI=";
  };

  build-system = [poetry-core];

  dependencies = [
    requests
    mutagen
    tidalapi
    dataclasses-json
    pathvalidate
    m3u8
    coloredlogs
    rich
    toml
    typer
    python-ffmpeg
    pycryptodome
  ];

  pythonRelaxDeps = [
    "requests"
    "pathvalidate"
    "typer"
    "rich"
  ];
}
