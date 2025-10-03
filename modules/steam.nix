{ config, lib, pkgs, unstable, ...}:

{
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [ unstable.proton-ge-bin ];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.protontricks.enable = true;
}

