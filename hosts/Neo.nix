{ config, pkgs, unstable, home-manager, ...}:

{

  home.stateVersion = "22.11";


  home.packages = [

    # General (Neo-specific)
    pkgs.pulsemixer
    pkgs.acpi
    pkgs.dmenu
    pkgs.wl-clipboard

    # AI (Neo-specific)
    unstable.claude-code
  ];


  programs.home-manager.enable = true;

}

