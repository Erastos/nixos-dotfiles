{ pkgs, mkDevShell }: mkDevShell {
  name     = "web";
  packages = with pkgs; [
    burpsuite sqlmap ffuf gobuster
    unstable.feroxbuster
    curl wget httpie nikto proxychains-ng wfuzz
  ];
}
