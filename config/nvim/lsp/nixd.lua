return {
  filetypes = { "nix" },
  cmd = { "nixd" },
  root_markers = { "flake.nix" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = [[import <nixpkgs> {}]]
      },
      options = {
        nixos = {
          expr = [[(builtins.getFlake (builtins.getEnv "DOTFILES_HOME")).nixosConfigurations.thunkbox.options]]
        },
      },
    }
  },
}
