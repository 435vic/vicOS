{
  lib,
  fetchFromGitHub,
  rustPlatform,
  copyDesktopItems,
  curl,
  perl,
  pkg-config,
  protobuf,
  xcbuild,
  fontconfig,
  freetype,
  libgit2,
  openssl,
  sqlite,
  zlib,
  zstd,
  alsa-lib,
  libxkbcommon,
  wayland,
  xorg,
  stdenv,
  darwin,
  makeFontsConf,
  vulkan-loader,
}:

rustPlatform.buildRustPackage rec {
  pname = "zed";
  version = "main-7b6f8c2";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "zed";
    rev = "7b6f8c279d17e6cbcf41643e6a5077971c952be1";
    hash = "sha256-uMATTq1SV9XwdJV4G4K0QyEYcaWHkgW7J+D7cHJ5OUA=";
    fetchSubmodules = true;
  };

  cargoHash = lib.fakeSha256;

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    copyDesktopItems
    curl
    perl
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ]; 
  
  buildInputs = [
    curl
    fontconfig
    freetype
    libgit2
    openssl
    sqlite
    zlib
    zstd
    alsa-lib
    libxkbcommon
    wayland
    xorg.libxcb
  ];

  #buildFeatures = [ "gpui/runtime_shaders" ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [
        "${src}/assets/fonts/zed-mono"
        "${src}/assets/fonts/zed-sans"
      ];
    };
  };

  postFixup = ''
    patchelf --add-rpath ${vulkan-loader}/lib $out/bin/*
    patchelf --add-rpath ${wayland}/lib $out/bin/*
  '';

  checkFlags = lib.optionals stdenv.hostPlatform.isLinux [
    # Fails with "On 2823 Failed to find test1:A"
    "--skip=test_base_keymap"
    # Fails with "called `Result::unwrap()` on an `Err` value: Invalid keystroke `cmd-k`"
    # https://github.com/zed-industries/zed/issues/10427
    "--skip=test_disabled_keymap_binding"
  ];

  postInstall = ''
    mv $out/bin/Zed $out/bin/zed
    install -D ${src}/crates/zed/resources/app-icon@2x.png $out/share/icons/hicolor/1024x1024@2x/apps/zed.png
    install -D ${src}/crates/zed/resources/app-icon.png $out/share/icons/hicolor/512x512/apps/zed.png
    install -D ${src}/crates/zed/resources/zed.desktop $out/share/applications/dev.zed.Zed.desktop
  '';

  meta = with lib; {
    description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
    homepage = "https://zed.dev";
    mainProgram = "zed";
  };
}
