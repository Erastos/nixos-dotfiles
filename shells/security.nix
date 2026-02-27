{ pkgs, mkDevShell }: mkDevShell {
  name     = "security";
  packages = with pkgs; [
    nmap unstable.netexec gobuster unstable.seclists
    netcat-openbsd responder hashcat
    unstable.metasploit wireshark tcpdump
    impacket bloodhound binwalk xxd curl
  ];
}
