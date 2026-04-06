{
  stdenv,
  lib,
  fetchurl,
  writeShellScript,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  cups,
  dbus,
  desktop-file-utils,
  gtk3,
  hicolor-icon-theme,
  libffi,
  libglvnd,
  libgcrypt,
  libpulseaudio,
  libva,
  libxkbcommon,
  libxscrnsaver,
  mesa,
  nss,
  pciutils,
  qt6,
  systemd,
  vulkan-loader,
  widevine-cdm,
  xdg-utils,
  liberation_ttf,
  commandLineArgs ? [],
  enableWideVine ? false,
}:
stdenv.mkDerivation rec {
  pname = "helium";
  version = "0.10.8.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/0.10.8.1/helium-0.10.8.1-x86_64_linux.tar.xz";
    hash = "sha256-qu0GvCbg4Eq1cHrTerOzH98KkL0FCSVQgLe+QWyH9d4=";
  };

  heliumWrapper = writeShellScript "helium-flags-wrapper" ''
    HERE="''${HELIUM_HOME:?HELIUM_HOME is not set}"

    SYS_CONF="/etc/helium-flags.conf"
    USR_CONF="''${XDG_CONFIG_HOME:-"$HOME/.config"}/helium-flags.conf"

    FLAGS=()

    append_flags_file() {
      local file="$1"
      [[ -r "$file" ]] || return 0
      local line safe_line
      while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
        case "$line" in
          *\$\(*|*\`*)
            echo "Warning: ignoring unsafe line in $file: $line" >&2
            continue
            ;;
        esac
        set -f
        safe_line=''${line//$/\\$}
        safe_line=''${safe_line//~/\\~}
        eval "set -- $safe_line"
        set +f
        for token in "$@"; do
          FLAGS+=("$token")
        done
      done < "$file"
    }

    append_flags_file "$SYS_CONF"
    append_flags_file "$USR_CONF"

    if [[ -n "''${HELIUM_USER_FLAGS:-}" ]]; then
      read -r -a ENV_FLAGS <<< "$HELIUM_USER_FLAGS"
      FLAGS+=("''${ENV_FLAGS[@]}")
    fi

    exec < /dev/null
    exec > >(exec cat)
    exec 2> >(exec cat >&2)

    exec "$HERE/helium" "''${FLAGS[@]}" "$@"
  '';

  ungoogledChromiumLicense = fetchurl {
    url = "https://raw.githubusercontent.com/imputnet/helium-linux/${version}/LICENSE.ungoogled_chromium";
    hash = "sha256-lTmzlOQXmVJpiJS9Yu9lZraASrD/Ng3POlEc+vf3jE0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    cups
    dbus
    desktop-file-utils
    gtk3
    hicolor-icon-theme
    liberation_ttf
    libffi
    libglvnd
    libgcrypt
    libpulseaudio
    libva
    libxkbcommon
    libxscrnsaver
    mesa
    nss
    pciutils
    qt6.qtbase
    systemd
    vulkan-loader
    xdg-utils
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
  ];

  installPhase = ''
    runHook preInstall

    heliumRoot="$out/libexec/${pname}"

    install -dm755 "$heliumRoot"
    find . -mindepth 1 -maxdepth 1 ! -name '$out' -exec mv -t "$heliumRoot" -- {} +

    rm -f "$heliumRoot/libEGL.so" "$heliumRoot/libGLESv2.so" "$heliumRoot/libvulkan.so.1"
    ln -s "${libglvnd}/lib/libEGL.so.1" "$heliumRoot/libEGL.so"
    ln -s "${libglvnd}/lib/libGLESv2.so.2" "$heliumRoot/libGLESv2.so"
    ln -s "${vulkan-loader}/lib/libvulkan.so.1" "$heliumRoot/libvulkan.so.1"

    ${lib.optionalString enableWideVine ''
      ln -s "${widevine-cdm}/share/google/chrome/WidevineCdm" "$heliumRoot/WidevineCdm"
    ''}

    find "$heliumRoot" -type f -name '*.so*' -exec chmod 0644 {} +

    install -dm755 "$heliumRoot/resources/ublock"
    cat > "$heliumRoot/resources/ublock/managed_storage.json" <<'EOF'
    {
      "type": "object",
      "properties": {}
    }
    EOF

    install -Dm644 "$heliumRoot/helium.desktop" "$out/share/applications/helium.desktop"
    install -Dm644 "$heliumRoot/product_logo_256.png" "$out/share/pixmaps/helium.png"
    install -Dm644 "$heliumRoot/product_logo_256.png" "$out/share/icons/hicolor/256x256/apps/helium.png"
    install -Dm644 "$ungoogledChromiumLicense" "$out/share/licenses/${pname}/LICENSE.ungoogled_chromium"

    makeWrapper "$heliumWrapper" "$out/bin/helium" \
      --set-default CHROME_VERSION_EXTRA "nixpkgs" \
      --set-default CHROME_WRAPPER "$out/bin/helium" \
      --append-flags "''${commandLineArgs[*]}" \
      --set HELIUM_HOME "$heliumRoot" \
      --prefix LD_LIBRARY_PATH : "$heliumRoot:$heliumRoot/lib:$heliumRoot/lib.target:${lib.makeLibraryPath [
      libglvnd
      mesa
    ]}"

    ln -s "$out/bin/helium" "$out/bin/helium-browser"

    runHook postInstall
  '';

  postFixup = ''
    heliumRoot="$out/libexec/${pname}"

    rm -f "$heliumRoot/libEGL.so" "$heliumRoot/libGLESv2.so" "$heliumRoot/libvulkan.so.1"
    ln -s "${libglvnd}/lib/libEGL.so.1" "$heliumRoot/libEGL.so"
    ln -s "${libglvnd}/lib/libGLESv2.so.2" "$heliumRoot/libGLESv2.so"
    ln -s "${vulkan-loader}/lib/libvulkan.so.1" "$heliumRoot/libvulkan.so.1"
  '';

  meta = with lib; {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-linux";
    mainProgram = "helium";
    platforms = ["x86_64-linux"];
    license =
      [
        licenses.gpl3Only
        licenses.bsd3
      ]
      ++ optional enableWideVine licenses.unfree;
  };
}
