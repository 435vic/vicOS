{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.hardware.wifi;
  interfaces = config.networking.wireless.interfaces;
in {
  options.vicos.hardware.wifi.enable = mkEnableOption "wifi";

  config = mkIf cfg.enable {
    networking.wireless.enable = true;

    networking = {
      useDHCP = false;
      useNetworkd = true;
      supplicant = listToAttrs (map (
          iface:
            nameValuePair iface {
              userControlled = {
                enable = true;
                group = "users";
              };
              configFile = {
                path = "/etc/wpa_supplicant.d/${iface}.conf";
                writable = true;
              };
              extraConf = ''
                ap_scan=1
                p2p_disabled=1
                okc=1
              '';
            }
        )
        interfaces);
    };

    systemd = {
      network = {
        networks = {
          "30-wired" = {
            enable = true;
            name = "en*";
            networkConfig.DHCP = "yes";
            networkConfig.IPv6PrivacyExtensions = "kernel";
            linkConfig.RequiredForOnline = "no"; # don't hang at boot (if dc'ed)
            dhcpV4Config.RouteMetric = 1024;
          };
          "30-wireless" = {
            enable = true;
            name = "wl*";
            networkConfig.DHCP = "yes";
            networkConfig.IPv6PrivacyExtensions = "kernel";
            linkConfig.RequiredForOnline = "no"; # don't hang at boot (if dc'ed)
            dhcpV4Config.RouteMetric = 2048; # prefer wired
          };
        };

        wait-online.enable = false;
      };

      tmpfiles.rules =
        ["d /etc/wpa_supplicant.d 700 root root - -"]
        ++ (map (iface: "f /etc/wpa_supplicant.d/${iface}.conf 700 root root - -") interfaces);
    };
  };
}
