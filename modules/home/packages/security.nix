{ config, lib, pkgs, ... }:

let
  cfg = config.netscape.packages.security;
in
{
  options.netscape.packages.security = {
    enable = lib.mkEnableOption "security and penetration testing tools" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Security
      wireshark
      nmap
      unstable.netexec
      gobuster
      seclists
      netcat-openbsd
      responder
      python313
      unstable.metasploit
      inetutils
      apktool
      jadx
      android-tools
      binwalk
      realm-studio
      dex2jar
      unstable.ghidra-bin
      quark-engine
      exiftool
      foremost
      openstego
      aapt
      hashcat
      hashid
      evil-winrm
      # python313Packages.impacket
      socat
      smap
      sdlookup
      python313Packages.shodan
      smbclient-ng
    ];
  };
}
