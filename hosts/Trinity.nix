{ config, pkgs, unstable, ...}:

{
  home.stateVersion = "22.11";

  home.packages = [
    # Security (Trinity-specific)
    pkgs.python313Packages.impacket
  ];
}

