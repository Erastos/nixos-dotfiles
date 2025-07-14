{ config, lib, pkgs, home-manager, ...}:

{

programs.zsh = {
  enable = true;
  history.size = 1000;
  history.save = 100000;
  history.share = true;

};

}

