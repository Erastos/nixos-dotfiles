{ config, lib, pkgs, ...}:

{
  networking.hostName = "Trinity";
  networking.networkmanager.enable = true;
}
