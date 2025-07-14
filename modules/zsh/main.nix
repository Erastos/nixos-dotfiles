{ config, lib, pkgs, home-manager, ...}:

{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";
    history.size = 1000;
    history.save = 100000;
    history.share = false;

    zprof.enable = false;

  };

}

