{ lib, config, ... }:
let
  user = config.vicos.user;
in
{
  options.home = {
    configFile = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      description = "Alias of stash files, to be linked to ~/.config";
    };

    file = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      description = "Alias of stash files, to be linked to ~";
    };
  };

  config = {
    lib.vicos.stash =
      path:
      config.lib.stash.fromStash {
        stash = "vicos";
        inherit path;
      };

    stash.users.${user} = {
      stashes.vicos = {
        path = "vicOS"; # at ~/vicOS
        init = {
          enable = true;
          source = {
            type = "git";
            url = "https://github.com/435vic/vicOS.git";
            ref = "main";
          };
        };
      };

      files =
        (lib.mapAttrs' (n: v: {
          name = ".config/${n}";
          value = v // {
            target = ".config/${n}";
          };
        }) config.home.configFile)
        // config.home.file;
    };
  };
}
