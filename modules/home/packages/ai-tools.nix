{ pkgs, ... }: {
  home.packages = [
    pkgs.unstable.opencode
    pkgs.unstable.claude-code
    pkgs.beads
    pkgs.gastown
  ];
}
