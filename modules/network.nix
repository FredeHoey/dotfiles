{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.net;
in {

  options.net = {
    enable = mkEnableOption "Default bun networking";
    lan-interface = mkOption { type = types.str; };
    hostname = mkOption { type = types.str; };
    wireless-interface = mkOption { 
      type = types.nullOr types.str;
      default = null; 
    };
  };

  config = mkIf (cfg.enable) {
    networking = {
      useDHCP = false;
      hostName = cfg.hostname;
      nameservers = [ "1.1.1.1" "1.0.0.1" ];
      wireless.iwd = {
        enable = (cfg.wireless-interface != null);
        settings = {
          General.EnableNetworkConfiguration = true;
        };
      };
      firewall.enable = false;
    };

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      dnsovertls = "true";
    };

    services.tailscale.enable = true;

    systemd.network = {
      enable = true;
      links = {
        "10-lan" = {
          matchConfig.Name = cfg.lan-interface;
          linkConfig.WakeOnLan = "magic";
        };
      };
      networks = {
        "10-lan" = {
          matchConfig.Name = cfg.lan-interface;
          networkConfig.DHCP = "ipv4";
        };
      };
    };
  };
}
