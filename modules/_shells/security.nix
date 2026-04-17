{ pkgs, mkDevShell }: mkDevShell {
  name     = "security";
  packages = with pkgs; [
    nmap unstable.netexec gobuster seclists
    netcat-openbsd responder hashcat
    unstable.metasploit wireshark tcpdump
    python3Packages.impacket bloodhound binwalk xxd curl
  ];
}
