{ config, lib, pkgs, home-manager, ...}:

{
  programs.zsh.zplug = {
      enable = true;
      plugins = [];
    };

}
