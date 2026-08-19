{ pkgs, mkDevShell }: mkDevShell {
  packages = with pkgs; [
    nmap unstable.netexec unstable.bloodhound-ce gobuster seclists
    netcat-openbsd responder hashcat
    unstable.metasploit wireshark tcpdump
    python3Packages.impacket bloodhound binwalk xxd curl
  ];
}
