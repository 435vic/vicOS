{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  kdePackages,
  wayland,
}:
# Compiled QML modules from Pond's interface (github.com/bflycomputer/pond-interface):
# Pond.System (logind sleep inhibitor, caps lock, network status) and Pond.Daylight
# (the lockscreen sky), plus Pond's Plymouth theme. The QML shell and lockscreen
# themselves are vendored and adapted under config/quickshell.
stdenv.mkDerivation {
  pname = "pond-interface";
  version = "0-unstable-2026-11-20";

  src = fetchFromGitHub {
    owner = "bflycomputer";
    repo = "pond-interface";
    rev = "7825829b44dea6a6a0fba1c3d1c5440bec1e00ed";
    hash = "sha256-KiI32YFJHWS+ViRZNOJgjcxsVdeGUxw/LE3kEssSDiE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.qtshadertools
  ];
  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    kdePackages.networkmanager-qt
    wayland
  ];
  dontWrapQtApps = true;

  cmakeFlags = [ (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_RPATH" true) ];
  buildPhase = ''
    runHook preBuild
    cmake --build . --target pond_systemplugin
    qsb --qt6 -o sky.frag.qsb ../wallpaper/daylight/sky.frag
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    qml=$out/${qt6.qtbase.qtQmlPrefix}
    install -Dm755 libpond_system.so Pond/System/libpond_systemplugin.so -t $qml/Pond/System
    install -Dm644 Pond/System/{qmldir,pond_system.qmltypes} -t $qml/Pond/System
    install -Dm644 ../wallpaper/daylight/{Sky.qml,SkyState.js,qmldir} sky.frag.qsb -t $qml/Pond/Daylight
    theme=$out/share/plymouth/themes/pond
    install -Dm644 ../plymouth/pond.script -t $theme
    cp -r ../plymouth/assets $theme/
    substitute ../plymouth/pond.plymouth $theme/pond.plymouth \
      --replace-fail /usr/share/plymouth/themes/pond $theme
    install -Dm644 ../LICENSE -t $out/share/licenses/pond-interface
    runHook postInstall
  '';

  meta = {
    description = "Compiled QML modules and Plymouth theme from the Pond desktop interface";
    homepage = "https://github.com/bflycomputer/pond-interface";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
}
