{ lib, config, ... }:
{
  options = with lib; {
    vicos = {
      user = mkOption {
        type = types.str;
        description = "Primary user for this machine.";
      };

      configPath = mkOption {
        type = types.str;
        description = ''
          Path to this flake. Config files declared in this flake will
          be symlinked to ~/.config from the specified path, and a systemd service
          will clone this git repo to this path on boot (if it doesn't exist).

          Must be writeable by the user.
        '';
      };
    };
  };

  config = {
    vicos.configPath = lib.mkDefault "${config.users.users.${config.vicos.user}.home}/vicos";
    users.users.${config.vicos.user} = {
      isNormalUser = true;
      uid = lib.mkDefault 1000;
      home = lib.mkDefault "/home/${config.vicos.user}";
    };
  };
}
