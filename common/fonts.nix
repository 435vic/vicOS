# taken from github:sioodmy/dotfiles
{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      lexend
      lato
      noto-fonts
      noto-fonts-emoji
      jetbrains-mono
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "SpaceMono"
        ];
      })
    ];

    enableDefaultPackages = false;

    fontconfig = {
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "JetBrainsMono"
        ];

        sansSerif = [
          "Lexend"
          "Noto Sans"
        ];

        serif = [
          "Noto Serif"
          "Noto Color Emoji"
        ];

        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
