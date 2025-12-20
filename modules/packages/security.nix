{ config, lib, pkgs, unstable, ... }:

let
  cfg = config.netscape.packages.security;
in
{
  options.netscape.packages.security = {
    enable = lib.mkEnableOption "security and penetration testing tools" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.netscape = {
      home.packages = with pkgs; [
        # Security
        wireshark
        nmap
        unstable.netexec
        gobuster
        unstable.seclists
        netcat-openbsd
        responder
        python313
        unstable.metasploit
        inetutils
      ];
    };
  };
}
