{
  pkgs,
  jdk ? pkgs.jdk21,
}:
pkgs.mkShellNoCC {
  packages = [
    pkgs.jdt-language-server
    (pkgs.callPackage pkgs.gradle-packages.gradle_8 {
      java = jdk;
    })
    pkgs.maven
    jdk
  ];
}
