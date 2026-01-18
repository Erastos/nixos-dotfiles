{ config, lib, pkgs, ... }:

{
  services.picom = {
    backend = "glx";
    enable = true;
    activeOpacity = 0.9;
    inactiveOpacity = 0.8;
    opacityRules = [ "100:fullscreen" ];
  };
}
