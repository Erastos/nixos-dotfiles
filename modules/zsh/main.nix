{ config, lib, pkgs, home-manager, ...}:

{

programs.zsh = {
  enable = true;
  shellAliases = {
    update = "sudo nixos-rebuild switch --flake '.#default'";
  };
  history.size = 1000;
  history.save = 100000;
  history.share = true;

  zplug = {
      enable = true;
      plugins = [
        { name = "iplaces/astro-zsh-theme"; tags = [ as:theme ]; }
      ];
    };
};

}

