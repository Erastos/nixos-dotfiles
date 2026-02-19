{ config, pkgs, ...}:

{
  home.stateVersion = "22.11";

  home.packages = [
    # General (Neo-specific)
    pkgs.pulsemixer
    pkgs.acpi
    pkgs.dmenu
    pkgs.wl-clipboard

    # AI (Neo-specific)
    pkgs.unstable.claude-code
  ];
}

