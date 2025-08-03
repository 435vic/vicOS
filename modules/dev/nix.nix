{pkgs, ...}: {
  # Enable nil and nixd for dotfiles
  # This is the only time we install development deps globally
  # It's fine, since nix is already installed system wide
  vicos.user.packages = with pkgs.unstable; [nil nixd];
}
