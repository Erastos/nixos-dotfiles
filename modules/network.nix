{ config, lib, pkgs, ...}:

{
  networking.hostName = config.systemName;
  networking.networkmanager.enable = true;
}
