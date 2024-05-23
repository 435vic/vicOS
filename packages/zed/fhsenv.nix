#    (pkgs.buildFHSEnv {
#      name = "zed";
#      targetPkgs = pkgs: [pkgs.zed-editor];
#      extraInstallCommands = ''
#        mkdir -p $out/share/applications
#        ln -s ${pkgs.zed-editor}/share/icons $out/share
#        ln -s ${pkgs.zed-editor}/share/applications/dev.zed.Zed.desktop $out/share/applications/dev.zed.Zed.desktop
#      '';
#      runScript = pkgs.writeShellScript "zed-wrapper.sh" ''
#        export WAYLAND_DISPLAY=
#        exec zed "$@"
#      '';
#    })

{ buildFHSEnv, local, writeShellScript }:

{
   name = "zed";
   targetPkgs = pkgs: [local.zed-editor];
   extraInstallCommands = ''
     mkdir -p $out/share/applications
     ln -s ${local.zed-editor}/share/icons $out/share
     ln -s ${local.zed-editor}/share/applications/dev.zed.Zed.desktop $out/share/applications/dev.zed.Zed.desktop
   '';
   runScript = writeShellScript "zed-wrapper.sh" ''
     export WAYLAND_DISPLAY=
     exec zed "$@"
   '';
}
