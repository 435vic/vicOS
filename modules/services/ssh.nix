{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.vicos.services.ssh;
in {
  options.vicos.services.ssh = {
    enable = mkEnableOption "ssh preset";
  };

  config = {
    # Ensure this directory exists and has correct permissions.
    systemd.user.tmpfiles.rules = ["d %h/.config/ssh 700 - - - -"];

    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        # Require keys over passwords. Ensure target machines are provisioned
        # with authorizedKeys!
        PasswordAuthentication = false;
      };
      # Suppress superfluous TCP traffic on new connections. Undo if using SSSD.
      extraConfig = ''GSSAPIAuthentication no'';
      # Removes the default RSA key (not that it represents a vulnerability, per
      # se, but is one less key (that I don't plan to use) to the castle laying
      # around) and improves the ed25519 key's entropy by generating it with 100
      # rounds (default is 16).
      hostKeys = [
        {
          comment = "${config.networking.hostName}.local";
          path = "/etc/ssh/ssh_host_ed25519_key";
          rounds = 100;
          type = "ed25519";
        }
      ];
    };
  };
}
