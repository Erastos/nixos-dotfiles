{ config, lib, pkgs, ...}:

{
  users.users.netscape = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
