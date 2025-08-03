{
  config,
  pkgs,
  ...
}: {
  vicos = {
    dev.nvim = {
      pure = false;
      package = config.vicos.flake.packages.vvim-wsl.impure;
    };
    shell = {
      fish.runByDefault = true;
      starship.enable = true;
      tmux.enable = true;
      git = {
        name = "Victor Quintana";
        email = "435victorjavier@gmail.com";
      };
    };
  };

  wsl.enable = true;
  wsl.defaultUser = "vico";
}
