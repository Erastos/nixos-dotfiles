{ config, lib, pkgs, callPackage, ...}:

{
  environment.pathsToLink = [ "/libexec" ];

  services.xserver = {
    enable = true;
    # autorun = false;

    desktopManager = {
      xterm.enable = false;
    };
    
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };
}
