{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs.unstable; [
      lexend
      lato
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-emoji
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.space-mono
      nerd-fonts.symbols-only
      # (nerdfonts.override {
      #   fonts = [
      #     "JetBrainsMono"
      #     "SpaceMono"
      #   ];
      # })
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