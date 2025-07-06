{ config, lib, pkgs, ...}:

{
  fonts.pkgs = [
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.blex-mono
  ];
}
