{
  pkgs,
  jdk ? pkgs.jdk21,
}:
pkgs.mkShellNoCC {
  packages = [
    pkgs.jdt-language-server
    (pkgs.gradle_8.override {
      java = jdk;
    })
    pkgs.maven
    jdk
  ];
}
