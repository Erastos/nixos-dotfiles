{ config, pkgs, unstable, home-manager, ...}:

{

  home.stateVersion = "22.11";


  home.packages = [

    # Security (Trinity-specific)
    pkgs.python313Packages.impacket
  ];

  programs.home-manager.enable = true;
}

