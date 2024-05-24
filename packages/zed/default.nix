{
  lib,
  buildFHSEnv,
  writeShellScript,
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
}: let
  commit = "1e5389a2be36218b78439ebb1eddbac1bd256670";
  shortCommit = builtins.substring 0 7 commit;
  zed = rustPlatform.buildRustPackage rec {
    pname = "zed-editor";
    version = "main-${shortCommit}";

    src = fetchFromGitHub {
      owner = "zed-industries";
      repo = "zed";
      rev = commit;
      hash = "sha256-/wbwYjqYBntbVV3QjwEMy/+1HCACA0hL/it+9onCw2s=";
      fetchSubmodules = true;
    };

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

    buildFeatures = ["gpui/runtime_shaders"];

    cargoBuildFlags = ["--package zed --package cli"];

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

    doCheck = false;

    postInstall = ''
      install -D ${src}/crates/zed/resources/app-icon-dev@2x.png $out/share/icons/hicolor/1024x1024@2x/apps/zed.png
      install -D ${src}/crates/zed/resources/app-icon-dev.png $out/share/icons/hicolor/512x512/apps/zed.png
      install -D ${src}/crates/zed/resources/zed.desktop $out/share/applications/dev.zed.Zed-Dev.desktop
    '';

    meta = with lib; {
      description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
      homepage = "https://zed.dev";
      mainProgram = "zed";
    };
  };
in
  buildFHSEnv {
    name = "zed";
    targetPkgs = pkgs: [
      zed
      pkgs.cargo
      pkgs.rustc
    ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      ln -s ${zed}/share/icons $out/share
      ln -s ${zed}/share/applications/dev.zed.Zed-Dev.desktop $out/share/applications/dev.zed.Zed-Dev.desktop
    '';
    #runScript = writeShellScript "zed-wrapper.sh" ''
    #  export WAYLAND_DISPLAY=
    #  exec ${final}/bin/zed "$@"
    #'';
    runScript = "${zed}/bin/cli";
  }
