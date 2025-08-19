{ config, lib, pkgs, ...}:

{
  services.xserver.videoDrivers = ["modesetting"];
}
