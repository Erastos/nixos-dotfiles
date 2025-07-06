{ config, lib, pkgs, ...}:

{
  fonts.packages = [
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.blex-mono
  ];
}
