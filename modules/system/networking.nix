{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.system.networking;
in
{
  options.netscape.system.networking = {
    networkManager = {
      enable = lib.mkEnableOption "NetworkManager" // { default = true; };
    };

    ssh = {
      enable = lib.mkEnableOption "OpenSSH server" // { default = true; };
    };

    tailscale = {
      enable = lib.mkEnableOption "Tailscale VPN" // { default = true; };
    };

    firewall.http = {
      enable = lib.mkEnableOption "Allow HTTP traffic through the firewall";
    };

    firewall.rtp = {
      enable = lib.mkEnableOption "Allow RTP traffic through the firewall" // { default = true; };
    };
  };

  config = lib.mkMerge [
    # NetworkManager and hostname
    (lib.mkIf cfg.networkManager.enable {
      assertions = [
        {
          assertion = config.netscape.systemName != null && config.netscape.systemName != "";
          message = "systemName must be set to a non-empty value";
        }
      ];
      networking.hostName = config.netscape.systemName;
      networking.networkmanager.enable = true;
    })

    # SSH
    (lib.mkIf cfg.ssh.enable {
      services.openssh.enable = true;
    })

    # Tailscale
    (lib.mkIf cfg.tailscale.enable {
      services.tailscale.enable = true;
    })

    # Firewall HTTP
    (lib.mkIf cfg.firewall.http.enable {
      networking.firewall.allowedTCPPorts = [ 8000 ];
    })
    # Firewall RTP
    (lib.mkIf cfg.firewall.rtp.enable {
      networking.firewall.allowedUDPPorts = [ 16384 32768 ];
      networking.firewall.allowedUDPPortRanges = [ { from = 10000; to = 20000; } ];
    })
  ];
}
