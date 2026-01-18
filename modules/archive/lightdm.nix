{ config, lib, pkgs, callPackage, ...}:

{
   services.xserver.displayManager.lightdm = {
     enable = true;
   };
}
