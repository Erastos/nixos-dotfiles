{ config, pkgs, unstable, home-manager, ...}:

{

  home.stateVersion = "22.11";


  home.packages = [

    # Containers/DevOps (Trinity-specific)
    pkgs.packer

    # Security (Trinity-specific)
    pkgs.python313Packages.impacket
  ];


  programs.home-manager.enable = true;

}

