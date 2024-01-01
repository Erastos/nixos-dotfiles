{ config, lib, pkgs, home-manager, ...}:

{
  programs.zsh.prezto = {
    enable = true;
    prompt.theme = "adam2";
  };

}
