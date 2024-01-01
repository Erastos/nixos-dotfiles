{ config, lib, pkgs, home-manager, ...}:

{
  programs.zsh.zplug = {
      enable = true;
      plugins = [
        { name = "iplaces/astro-zsh-theme"; tags = [ as:theme ]; }
      ];
    };

}
