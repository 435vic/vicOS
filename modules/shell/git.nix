{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.shell.git;
in
{
  options.vicos.shell.git = {
    name = mkOption {
      type = types.str;
      description = "Name used to author git commits.";
    };

    email = mkOption {
      type = types.str;
      description = "Email used to author git commits.";
    };
  };

  config = {
    programs.git.enable = true;

    vicos.user.packages = with pkgs; [
      gitAndTools.gh
      gitAndTools.git-crypt
    ];

    home.configFile = {
      "git/config".text = ''
        [user]
          name = ${cfg.name}
          email = ${cfg.email}

        [core]
          whitespace = trailing-space

        [init]
          defaultBranch = main

        [credential "https://github.com"]
          helper =
          helper = !gh auth git-credential
        [credential "https://gist.github.com"]
          helper =
          helper = !gh auth git-credential
      '';

      "git/ignore".source = config.lib.vicos.fileFromConfig "git/ignore";
    };
  };
}
