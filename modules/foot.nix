{ config, lib, pkgs, unstable, home-manager, ...}:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Hack Nerd Font:size=12";
      };
    };
  };
}

