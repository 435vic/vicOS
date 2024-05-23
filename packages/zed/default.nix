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
  fhs = final:
    buildFHSEnv {
      name = "zed";
      targetPkgs = pkgs: [
        final
        pkgs.cargo
        pkgs.rustc
      ];
      extraInstallCommands = ''
        mkdir -p $out/share/applications
        ln -s ${final}/share/icons $out/share
        ln -s ${final}/share/applications/dev.zed.Zed.desktop $out/share/applications/dev.zed.Zed.desktop
      '';
      #runScript = writeShellScript "zed-wrapper.sh" ''
      #  export WAYLAND_DISPLAY=
      #  exec ${final}/bin/zed "$@"
      #'';
      runScript = "${final}/bin/zed";
    };
in
  rustPlatform.buildRustPackage rec {
    passthru = {
      fhs = final: fhs final;
    };

    pname = "zed-editor";
    version = "main-3eb0418";

    src = fetchFromGitHub {
      owner = "zed-industries";
      repo = "zed";
      rev = "3eb0418bda8b7c7e375f0a00ae65da99b5a8c054";
      hash = "sha256-uMATTq1SV9XwdJV4G4K0QyEYcaWHkgW7J+D7cHJ5OUA=";
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
      install -D ${src}/crates/zed/resources/app-icon-dev@2x.png $out/share/icons/hicolor/1024x1024@2x/apps/zed.png
      install -D ${src}/crates/zed/resources/app-icon-dev.png $out/share/icons/hicolor/512x512/apps/zed.png
      install -D ${src}/crates/zed/resources/zed.desktop $out/share/applications/dev.zed.Zed.desktop
    '';

    meta = with lib; {
      description = "High-performance, multiplayer code editor from the creators of Atom and Tree-sitter";
      homepage = "https://zed.dev";
      mainProgram = "zed";
    };
  }
