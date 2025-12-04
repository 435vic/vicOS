{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      lexend
      lato
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.space-mono
      nerd-fonts.symbols-only
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

        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
