{ config, lib, ... }:
let
  cfg = config.netscape.system.networking;
in {
  options.netscape.system.networking.firewall = {
    http.enable  = lib.mkEnableOption "Allow HTTP traffic through the firewall";
    shell.enable = lib.mkEnableOption "Allow Reverse Shell traffic through firewall" // { default = true; };
    smb.enable   = lib.mkEnableOption "Allow SMB Server through firewall" // { default = true; };
    wireshark.enable   = lib.mkEnableOption "Allow Wireshark Streaming" // { default = true; };
  };

  config = lib.mkMerge [
    {
      networking.networkmanager.enable = true;
      services.openssh.enable          = true;
      services.tailscale.enable        = true;
    }
    (lib.mkIf cfg.firewall.http.enable  { networking.firewall.allowedTCPPortRanges = [{ from = 8000; to = 8010; }]; })
    (lib.mkIf cfg.firewall.shell.enable { networking.firewall.allowedTCPPorts = [ 4444 9001 ]; })
    (lib.mkIf cfg.firewall.smb.enable   { networking.firewall.allowedTCPPorts = [ 445 ]; })
    (lib.mkIf cfg.firewall.wireshark.enable   { networking.firewall.allowedUDPPorts = [ 37008 ]; })
  ];
}
