{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  rustPlatform,
  appimageTools,
  autoPatchelfHook,
  addDriverRunpath,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  curl,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  libdrm,
  libgbm,
  libglvnd,
  libpulseaudio,
  libsecret,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  pipewire,
  sqlite,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
  gateOnly ? true,
}:

let
  pname = "discord-sunbird";
  discordBuild = "2233";
  sunbirdRev = "8559cbeeea56a430605217b065a7f020ff72fe4b";
  sunbirdVersion = "2026.11.26.1717-8559cbe";
  version = "${discordBuild}-sunbird-${sunbirdVersion}";

  appimage = fetchurl {
    url = "https://dl.redeem.saarland/desktop/${discordBuild}/linux-x64.AppImage";
    hash = "sha256-c4CO5T2i7w3JhFcYQL7A7TMR+p4u8SNsoBxc2C9Vmr4=";
  };

  libphoenix = rustPlatform.buildRustPackage {
    pname = "libphoenix";
    version = sunbirdVersion;

    src = fetchFromGitHub {
      owner = "sunbird-tools";
      repo = "sunbird";
      rev = sunbirdRev;
      hash = "sha256-qbhuihUV0sN9Ej38/A4N0SoGRR1EyIAjKKU1twt3ZGM=";
    };

    cargoHash = "sha256-zvsr8LAnZhCTQlgNPgoENyDXtcV8hKPu9s8Ry888xbE=";

    buildInputs = [ sqlite ];

    postPatch = ''
      substituteInPlace crates/runtime/build.rs \
        --replace-fail '.unwrap_or_else(|| "0".to_owned())' \
                       '.unwrap_or_else(|| "${sunbirdVersion}".to_owned())'
    '';

    cargoBuildFlags = [ "-p" "phoenix-loader" ];
    cargoTestFlags = [ "-p" "phoenix-loader" ];

    installPhase = ''
      runHook preInstall
      install -Dm755 target/*/release/libphoenix.so "$out/lib/libphoenix.so"
      runHook postInstall
    '';
  };

  extracted = appimageTools.extract {
    pname = "discord-phoenix";
    version = discordBuild;
    src = appimage;
  };

  # Libraries directly linked (DT_NEEDED) by discord-phoenix, helpers, libcef.so, and libphoenix.so
  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    libgbm
    libpulseaudio
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    sqlite
    systemd
  ];

  # Additional libraries loaded at runtime via dlopen (Wayland, Vulkan, VA-API, OpenGL, PipeWire, etc.)
  runtimeLibs = buildInputs ++ [
    curl
    fontconfig
    freetype
    libdrm
    libglvnd
    libsecret
    libva
    libxcursor
    libxi
    pipewire
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  inherit pname version buildInputs;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
    addDriverRunpath
    copyDesktopItems
  ];

  # Preserve $ORIGIN-relative lookups (e.g. $ORIGIN/../lib/discord-phoenix and libcef's $ORIGIN)
  # while ensuring dlopen'd libraries are also resolvable via RUNPATH.
  appendRunpaths = [
    "${lib.makeLibraryPath runtimeLibs}"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "com.discord.libdiscord";
      desktopName = "Discord Sunbird";
      genericName = "Internet Messenger";
      comment = "Discord Phoenix (Rust client) with Sunbird loader";
      exec = "discord-sunbird %U";
      icon = "com.discord.libdiscord";
      startupWMClass = "com.discord.libdiscord";
      categories = [
        "Network"
        "InstantMessaging"
      ];
      mimeTypes = [
        "x-scheme-handler/discord"
      ];
      startupNotify = true;
      terminal = false;
    })
  ];

  installPhase = ''
    runHook preInstall

    # Keep the exact usr/bin + usr/lib/discord-phoenix relative layout so
    # $ORIGIN/../lib/discord-phoenix and helper lookups resolve properly.
    mkdir -p "$out/libexec/discord-phoenix/bin" \
             "$out/libexec/discord-phoenix/lib" \
             "$out/lib/sunbird" \
             "$out/bin" \
             "$out/share"

    cp -a "${extracted}/usr/bin/discord-phoenix" "$out/libexec/discord-phoenix/bin/discord-phoenix"
    cp -a "${extracted}/usr/lib/discord-phoenix" "$out/libexec/discord-phoenix/lib/discord-phoenix"
    chmod -R u+w "$out/libexec/discord-phoenix"

    install -Dm755 "${libphoenix}/lib/libphoenix.so" "$out/lib/sunbird/libphoenix.so"

    if [ -d "${extracted}/usr/share/icons" ]; then
      cp -r "${extracted}/usr/share/icons" "$out/share/icons"
    fi

    cat > "$out/bin/discord-sunbird" <<EOF
#!${stdenv.shell}
set -eu
${lib.optionalString gateOnly "export SUNBIRD_GATE_ONLY=1"}
while [ "\''${1:-}" = --no-runtime ] || [ "\''${1:-}" = --gate-only ] || [ "\''${1:-}" = --with-runtime ]; do
  case "\$1" in
    --no-runtime|--gate-only) export SUNBIRD_GATE_ONLY=1 ;;
    --with-runtime) unset SUNBIRD_GATE_ONLY ;;
  esac
  shift
done
export PATH="${lib.makeBinPath [ xdg-utils ]}\''${PATH:+:\$PATH}"
export LD_PRELOAD="$out/lib/sunbird/libphoenix.so\''${LD_PRELOAD:+:\$LD_PRELOAD}"
exec "$out/libexec/discord-phoenix/bin/discord-phoenix" "\$@"
EOF
    chmod +x "$out/bin/discord-sunbird"

    runHook postInstall
  '';

  preFixup = ''
    # discord-openh264-helper dlopens an embedded libopenh264.so from a memfd
    # which depends on libstdc++.so.6; pre-linking it ensures it's already loaded.
    patchelf --add-needed libstdc++.so.6 "$out/libexec/discord-phoenix/lib/discord-phoenix/discord-openh264-helper"
  '';

  postFixup = ''
    # Add /run/opengl-driver/lib to RUNPATH for GPU/Vulkan/VA-API/CUDA drivers on NixOS
    addDriverRunpath "$out/libexec/discord-phoenix/bin/discord-phoenix"
    addDriverRunpath "$out/libexec/discord-phoenix/lib/discord-phoenix/discord_media"
    addDriverRunpath "$out/libexec/discord-phoenix/lib/discord-phoenix/video-codec-probe"
    addDriverRunpath "$out/libexec/discord-phoenix/lib/discord-phoenix/modules/discord_cef-0/discord_cef/libcef.so"
  '';

  meta = {
    description = "Discord Phoenix (Rust native client) patched with Sunbird loader";
    homepage = "https://sunbird.tools";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "discord-sunbird";
  };
}
