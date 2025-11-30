{ config, lib, pkgs, ...}:

{
  # ZSH
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
}
