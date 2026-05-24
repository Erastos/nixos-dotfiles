{ pkgs, claude-desktop, ... }: {
  home.packages = [
    pkgs.unstable.opencode
    pkgs.unstable.claude-code
    claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs
    pkgs.beads
    pkgs.gastown
  ];
}
